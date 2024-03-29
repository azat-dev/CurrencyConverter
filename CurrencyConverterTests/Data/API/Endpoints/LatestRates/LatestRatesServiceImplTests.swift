//
//  LatestRatesServiceImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import XCTest

import CurrencyConverter

final class LatestRatesServiceImplTests: XCTestCase {

    // swiftlint:disable large_tuple
    typealias SUT = (
        service: LatestRatesService,
        httpClient: HTTPClientMock,
        httpTask: HTTPClientTaskMock,
        dataMapper: LatestRatesEndpointDataMapperMock
    )
    // swiftlint:enable large_tuple

    func createSUT(baseURL: URL, appId: String) -> SUT {

        let httpTask = HTTPClientTaskMock()
        let httpClient = HTTPClientMock()

        httpClient.getWillReturn = { _ in
            return httpTask
        }

        let dataMapper = LatestRatesEndpointDataMapperMock()

        let service = LatestRatesServiceImpl(
            baseURL: baseURL,
            appId: appId,
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
        let url = anyBaseURL()
        let appId = "APP_ID"
        let sut = createSUT(baseURL: url, appId: appId)

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
        let url = anyBaseURL()
        let appId = "APP_ID"
        let sut = createSUT(baseURL: url, appId: appId)

        let testData = "data".data(using: .utf8)!
        let expectedRates = [
            "USD": 5.3
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        sut.httpTask.resultWillReturn = {
            .success((testData, response))
        }

        sut.dataMapper.willReturn = { _ in .success(expectedRates) }

        // When
        let result = await sut.service.fetch()

        // Then
        // Must succeed
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }

        XCTAssertEqual(receivedCurrencies, expectedRates)
    }

    // MARK: - Helpers

    func anyBaseURL() -> URL {
        return URL(string: "https://base-url.org")!
    }
}
