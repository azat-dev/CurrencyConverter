//
//  CurrenciesServiceCachedTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation
import XCTest

import CurrencyConverter

final class CurrenciesServiceCachedTests: XCTestCase {
    
    typealias SUT = (
        service: CurrenciesService,
        currenciesService: CurrenciesServiceMock,
        localStorage: LocalStorageMock,
        dateProvider: DateProviderMock
    )
    
    func createSUT(timeout: TimeInterval) -> SUT {
        
        let currenciesService = CurrenciesServiceMock()
        let localStorage = LocalStorageMock()
        
        let dateProvider = DateProviderMock()
        
        let service = CurrenciesServiceCached(
            currenciesService: currenciesService,
            timeout: timeout,
            localStorage: localStorage,
            dateProvider: dateProvider
        )
        
        return (
            service,
            currenciesService,
            localStorage,
            dateProvider
        )
    }
    
    // MARK: - Methods
    
    func test_fetch__fail() async throws {
        
        // Given
        let sut = createSUT(timeout: 1)
        
        sut.dateProvider.getCurrentDateWillReturn = Date()
        sut.currenciesService.fetchWillReturn = { .failure(.internalError) }
        
        sut.localStorage.getWillReturn = { _ in
            Result<CurrenciesServiceCached.CachedValue?, Error>.failure(NSError()) as Any
        }
        
        // When
        let result = await sut.service.fetch()
        
        // Then
        guard case .success = result else {
            return
        }
        
        // Must fail
        XCTFail("Must fail")
    }
    
    func test_fetch__success__put_in_cache__get_from_cache() async throws {
        
        // Given
        let sut = createSUT(timeout: 1)
        
        let expectedCurrencies = [
            "USD": "Dollar"
        ]
        
        let currentDate = Date()
        
        sut.dateProvider.getCurrentDateWillReturn = currentDate
        
        sut.localStorage.getWillReturn = { _ in
            Result<CurrenciesServiceCached.CachedValue?, Error>.failure(NSError()) as Any
        }
        
        sut.currenciesService.fetchWillReturn = {
            return .success(expectedCurrencies)
        }
        
        sut.localStorage.putWillReturn = { _, _ in .success(())}
        
        // When
        let result = await sut.service.fetch()
        
        // Then
        // Must succeed
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
        
        // Must put data in cache
        XCTAssertEqual(sut.currenciesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 1)
        
        // Given
        sut.localStorage.getWillReturn = { _ in
            Result<CurrenciesServiceCached.CachedValue?, Error>.success(
                .init(
                    date: currentDate,
                    value: expectedCurrencies
                )
            ) as Any
        }
        
        // When
        let resultFromCache = await sut.service.fetch()
        
        // Then
        guard case .success(let receivedCurrenciesFromCache) = resultFromCache else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertEqual(receivedCurrenciesFromCache, expectedCurrencies)
        
        // Verify getting the data from the cache
        XCTAssertEqual(sut.currenciesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 1)
        XCTAssertEqual(sut.localStorage.capturedGet.count, 2)
    }
    
    func test_fetch__invalidate_cache_by_time() async throws {
        
        // Given
        let timeout: TimeInterval = 1
        let sut = createSUT(timeout: timeout)
        
        let expectedCurrencies = [
            "USD": "Dollar"
        ]
        
        let currentDate = Date()
        
        sut.currenciesService.fetchWillReturn = {
            return .success(expectedCurrencies)
        }
        
        // Invalidate cache
        sut.dateProvider.getCurrentDateWillReturn = Date(timeIntervalSinceNow: timeout + 1)
        sut.localStorage.putWillReturn = { _, _ in .success(())}
        
        sut.localStorage.getWillReturn = { _ in
            Result<CurrenciesServiceCached.CachedValue?, Error>.success(
                .init(
                    date: currentDate,
                    value: expectedCurrencies
                )
            ) as Any
        }
        
        // When
        let _ = await sut.service.fetch()
        
        // Then
        // Must put new data in cache
        XCTAssertEqual(sut.currenciesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 1)
    }
    
    func test_fetch__invalidate_cache_by_time__fail_fetch_during_update() async throws {
        
        // Given
        let timeout: TimeInterval = 1
        let currentDate = Date()
        let sut = createSUT(timeout: timeout)
        
        let expectedCurrencies = [
            "USD": "Dollar"
        ]
        
        sut.currenciesService.fetchWillReturn = {
            return .failure(.internalError)
        }
        
        sut.localStorage.getWillReturn = { _ in
            Result<CurrenciesServiceCached.CachedValue?, Error>.success(
                .init(
                    date: currentDate,
                    value: expectedCurrencies
                )
            ) as Any
        }
        
        // Invalidate cache
        sut.dateProvider.getCurrentDateWillReturn = Date(timeIntervalSinceNow: timeout + 1)
        
        // When
        let result = await sut.service.fetch()
        
        // Then
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        // Must put data in cache
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
        XCTAssertEqual(sut.currenciesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 0)
    }
}

// MARK: - Helpers

class LocalStorageMock: LocalStorage {
    
    // MARK: - Types
    
    struct PutData {
        
        let key: String
        let value: Any
    }
    
    // MARK: - Properties
    
    var getWillReturn: ((_ key: String) -> Any)!
    
    var capturedPut = [PutData]()
    
    var capturedGet = [String]()
    
    var putWillReturn: ((_ key: String, _ value: Any) -> Result<Void, Error>)!
    
    var capturedDelete = [String]()
    
    var deleteWillReturn: ((_ key: String) -> Result<Void, Error>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func get<T>(key: String, as: T.Type) async -> Result<T?, Error> where T : Decodable, T : Encodable {
        
        capturedGet.append(key)
        return getWillReturn(key) as! Result<T?, Error>
    }
    
    func put<T>(key: String, value: T) async -> Result<Void, Error> where T : Decodable, T : Encodable {
        
        capturedPut.append(.init(key: key, value: value))
        return putWillReturn(key, value)
    }
    
    func delete(key: String) async -> Result<Void, Error> {
        
        capturedDelete.append(key)
        return deleteWillReturn(key)
    }
}

class DateProviderMock: DateProvider {
    
    // MARK: - Properties
    
    var getCurrentDateWillReturn: Date!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func getCurrentDate() -> Date {
        
        return getCurrentDateWillReturn
    }
}
