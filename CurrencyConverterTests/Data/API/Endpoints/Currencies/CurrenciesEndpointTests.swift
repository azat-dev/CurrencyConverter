//
//  CurrenciesEndpointTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation
import XCTest

import CurrencyConverter

final class CurrenciesEndpointTests: XCTestCase {

    func test_url() async throws {

        // Given
        let baseURL = URL(string: "https://base-url.com")!

        // When
        let receivedURL = CurrenciesEndpoint.get.url(baseURL: baseURL)

        // Then
        XCTAssertEqual(receivedURL.scheme, "https", "scheme")
        XCTAssertEqual(receivedURL.host, "base-url.com", "host")
        XCTAssertEqual(receivedURL.path, "/api/currencies.json", "path")
    }
}
