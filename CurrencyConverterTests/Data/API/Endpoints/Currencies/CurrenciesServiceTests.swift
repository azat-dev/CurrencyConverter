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

    struct SUTDependencies {

        let httpClient: HTTPClientMock
        let httpTask: HTTPClientTaskMock
        let dataMapper: CurrenciesEndpointDataMapperMock
    }

    typealias SUT = (
        service: CurrenciesService,
        dependencies: SUTDependencies
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
            dependencies: .init(
                httpClient: httpClient,
                httpTask: httpTask,
                dataMapper: dataMapper
            )
        )
    }

    // MARK: - Methods

    func test_fetch__fail() async throws {

        // Given
        let url = anyBaseURL()
        let sut = createSUT(baseURL: url)

        sut.dependencies.httpTask.resultWillReturn = {
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
        let sut = createSUT(baseURL: url)

        let testData = "data".data(using: .utf8)!
        let expectedCurrencies = [
            "USD": "Dollar"
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        sut.dependencies.httpTask.resultWillReturn = {
            .success((testData, response))
        }

        sut.dependencies.dataMapper.willReturn = { _ in .success(expectedCurrencies) }

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

    // MARK: - Helpers

    func anyBaseURL() -> URL {
        return URL(string: "https://base-url.org")!
    }
}
