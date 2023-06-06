//
//  CurrenciesServiceTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation
import XCTest

import CurrencyConverter

final class CurrenciesServiceTests: XCTestCase {
    
    typealias SUT = (
        service: CurrenciesService,
        httpClient: HTTPClientMock,
        httpTask: HTTPClientTaskMock,
        dataMapper: CurrenciesEndpointDataMapperMock
    )
    
    func createSUT(baseURL: URL) -> SUT {
        
        let httpTask = HTTPClientTaskMock()
        let httpClient = HTTPClientMock()
        
        httpClient.getWillReturn = { _ in
            return httpTask
        }
        
        let dataMapper = CurrenciesEndpointDataMapperMock()
        
        let service = CurrenciesServiceImpl(
            baseURL: baseURL,
            httpClient: httpClient,
            dataMapper: dataMapper
        )
        
        return (
            service,
            httpClient,
            httpTask,
            dataMapper
        )
    }
    
    // MARK: - Methods
    
    func test_fetch__fail() async throws {
        
        // Given
        let url = URL(string: "https://base-url.org")!
        let sut = createSUT(baseURL: url)
        
        sut.httpTask.resultWillReturn = {
            .failure(NSError(domain: "Some Error", code: 0))
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
    
    func test_fetch__success() async throws {
        
        // Given
        let url = URL(string: "https://base-url.org")!
        let sut = createSUT(baseURL: url)
        
        let testData = "data".data(using: .utf8)!
        let expectedCurrencies = [
            "USD": "Dollar"
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        sut.httpTask.resultWillReturn = {
            .success((testData, response))
        }
        
        sut.dataMapper.willReturn = { _ in .success(expectedCurrencies) }

        // When
        let result = await sut.service.fetch()
        
        // Then
        // Must succeed
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
    }
}

// MARK: - Helpers

class HTTPClientTaskMock: HTTPClientTask {
    
    // MARK: - Properties
    
    var isCanceled = false
    
    var resultWillReturn: (() async -> TaskResult)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func cancel() {
        isCanceled = true
    }
    
    func result() async -> TaskResult {
        
        await resultWillReturn()
    }
}

class HTTPClientMock: HTTPClient {
    
    // MARK: - Properties
    
    var getWillReturn: ((_ url: URL) -> HTTPClientTask)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func get(from url: URL) -> HTTPClientTask {
        return getWillReturn(url)
    }
}

class CurrenciesEndpointDataMapperMock: CurrenciesEndpointDataMapper {
    
    // MARK: - Properties
    
    var willReturn: ((_ data: Data) -> Result<[CurrencyCode : CurrencyTitle], CurrenciesEndpointDataMapperError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func map(_ data: Data) -> Result<[CurrencyCode : CurrencyTitle], CurrenciesEndpointDataMapperError> {
        
        return willReturn(data)
    }
}
