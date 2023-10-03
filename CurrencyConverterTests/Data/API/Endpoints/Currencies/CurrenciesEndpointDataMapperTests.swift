//
//  CurrenciesEndpointDataMapperTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation
import XCTest

import CurrencyConverter

final class CurrenciesEndpointDataMapperTests: XCTestCase {

    typealias SUT = CurrenciesEndpointDataMapper

    func createSUT() -> SUT {

        return CurrenciesEndpointDataMapperImpl()
    }

    // MARK: - Methods

    func test_map__invalid_data() async throws {

        // Given
        let sut = createSUT()
        let invalidJSONData = "invalid_json".data(using: .utf8)!

        // When
        let result = sut.map(invalidJSONData)

        // Then
        // Must fail
        guard case .success = result else {
            return
        }

        XCTFail("Must fail")
    }

    func test_map__success() async throws {

        // Given
        let sut = createSUT()

        let validJSONData = """
            {
                "AED": "United Arab Emirates Dirham",
                "AFN": "Afghan Afghani",
                "ALL": "Albanian Lek",
                "AMD": "Armenian Dram",
                "ANG": "Netherlands Antillean Guilder",
                "AOA": "Angolan Kwanza",
                "ARS": "Argentine Peso"
            }
        """.data(using: .utf8)!

        // When
        let result = sut.map(validJSONData)

        // Then

        guard case .success(let currencies) = result else {
            XCTFail("Must succeed")
            return
        }

        XCTAssertEqual(currencies.count, 7)
        XCTAssertEqual(currencies["AED"], "United Arab Emirates Dirham")
    }
}
