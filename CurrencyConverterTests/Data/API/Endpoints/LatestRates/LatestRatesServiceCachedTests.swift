//
//  LatestRatesServiceCachedTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import XCTest

import CurrencyConverter

final class LatestRatesServiceCachedTests: XCTestCase {

    // swiftlint:disable large_tuple
    typealias SUT = (
        service: LatestRatesService,
        latestRatesService: LatestRatesServiceMock,
        localStorage: LocalStorageMock,
        dateProvider: DateProviderMock
    )
    // swiftlint:enable large_tuple

    func createSUT(timeout: TimeInterval) -> SUT {

        let latestRatesService = LatestRatesServiceMock()
        let localStorage = LocalStorageMock()

        let dateProvider = DateProviderMock()

        let service = LatestRatesServiceCached(
            latestRatesService: latestRatesService,
            timeout: timeout,
            localStorage: localStorage,
            dateProvider: dateProvider
        )

        return (
            service,
            latestRatesService,
            localStorage,
            dateProvider
        )
    }

    // MARK: - Methods

    func test_fetch__fail() async throws {

        // Given
        let sut = createSUT(timeout: 1)

        sut.dateProvider.getCurrentDateWillReturn = Date()
        sut.latestRatesService.fetchWillReturn = { .failure(.internalError) }

        sut.localStorage.getWillReturn = { _ in
            // swiftlint:disable discouraged_direct_init
            Result<LatestRatesServiceCached.CachedValue?, Error>.failure(NSError()) as Any
            // swiftlint:enable discouraged_direct_init
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

        let expectedRates = [
            "USD": 1.111
        ]

        let currentDate = Date()

        sut.dateProvider.getCurrentDateWillReturn = currentDate

        sut.localStorage.getWillReturn = { _ in
            // swiftlint:disable discouraged_direct_init
            Result<LatestRatesServiceCached.CachedValue?, Error>.failure(NSError()) as Any
            // swiftlint:enable discouraged_direct_init
        }

        sut.latestRatesService.fetchWillReturn = {
            return .success(expectedRates)
        }

        sut.localStorage.putWillReturn = { _, _ in .success(())}

        // When
        let result = await sut.service.fetch()

        // Then
        // Must succeed
        guard case .success(let receivedRates) = result else {
            XCTFail("Must succeed")
            return
        }

        XCTAssertEqual(receivedRates, expectedRates)

        // Must put data in cache
        XCTAssertEqual(sut.latestRatesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 1)

        // Given
        sut.localStorage.getWillReturn = { _ in
            Result<LatestRatesServiceCached.CachedValue?, Error>.success(
                .init(
                    date: currentDate,
                    value: expectedRates
                )
            ) as Any
        }

        // When
        let resultFromCache = await sut.service.fetch()

        // Then
        guard case .success(let receivedRatesFromCache) = resultFromCache else {
            XCTFail("Must succeed")
            return
        }

        XCTAssertEqual(receivedRatesFromCache, expectedRates)

        // Verify getting the data from the cache
        XCTAssertEqual(sut.latestRatesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 1)
        XCTAssertEqual(sut.localStorage.capturedGet.count, 2)
    }

    func test_fetch__invalidate_cache_by_time() async throws {

        // Given
        let timeout: TimeInterval = 1
        let sut = createSUT(timeout: timeout)

        let expectedRates = [
            "USD": 1.111
        ]

        let currentDate = Date()

        sut.latestRatesService.fetchWillReturn = {
            return .success(expectedRates)
        }

        // Invalidate cache
        sut.dateProvider.getCurrentDateWillReturn = Date(timeIntervalSinceNow: timeout + 1)
        sut.localStorage.putWillReturn = { _, _ in .success(())}

        sut.localStorage.getWillReturn = { _ in
            Result<LatestRatesServiceCached.CachedValue?, Error>.success(
                .init(
                    date: currentDate,
                    value: expectedRates
                )
            ) as Any
        }

        // When
        _ = await sut.service.fetch()

        // Then
        // Must put new data in cache
        XCTAssertEqual(sut.latestRatesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 1)
    }

    func test_fetch__invalidate_cache_by_time__fail_fetch_during_update() async throws {

        // Given
        let timeout: TimeInterval = 1
        let currentDate = Date()
        let sut = createSUT(timeout: timeout)

        let expectedRates = [
            "USD": 1.111
        ]

        sut.latestRatesService.fetchWillReturn = {
            return .failure(.internalError)
        }

        sut.localStorage.getWillReturn = { _ in
            Result<LatestRatesServiceCached.CachedValue?, Error>.success(
                .init(
                    date: currentDate,
                    value: expectedRates
                )
            ) as Any
        }

        // Invalidate cache
        sut.dateProvider.getCurrentDateWillReturn = Date(timeIntervalSinceNow: timeout + 1)

        // When
        let result = await sut.service.fetch()

        // Then
        guard case .success(let receivedRates) = result else {
            XCTFail("Must succeed")
            return
        }

        // Must put data in cache
        XCTAssertEqual(receivedRates, expectedRates)
        XCTAssertEqual(sut.latestRatesService.fetchCount, 1)
        XCTAssertEqual(sut.localStorage.capturedPut.count, 0)
    }
}
