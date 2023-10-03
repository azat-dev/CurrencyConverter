//
//  LatestRatesEndpointTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import XCTest

import CurrencyConverter

final class LatestRatesEndpointTests: XCTestCase {

    func test_url() async throws {

        // Given
        let baseURL = URL(string: "https://base-url.com")!
        let appId = "APP_ID"

        // When
        let receivedURL = LatestRatesEndpoint.get.url(baseURL: baseURL, appId: appId)

        // Then
        XCTAssertEqual(receivedURL.scheme, "https", "scheme")
        XCTAssertEqual(receivedURL.host, "base-url.com", "host")
        XCTAssertEqual(receivedURL.path, "/api/latest.json", "path")
        XCTAssertEqual(receivedURL.query, "app_id=\(appId)", "query")
    }
}
