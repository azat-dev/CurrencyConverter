//
//  DataCoderJSONTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class DataCoderJSONTests: XCTestCase {

    typealias SUT = DataCoder

    func createSUT() -> SUT {

        let coder = DataCoderJSON()

        return coder
    }

    // MARK: - Methods

    func test_encode_decode() async throws {

        // Given
        let sut = createSUT()

        let testValue = [0, 1, 2]

        // When
        let encodedValue = try sut.encode(testValue)
        let decodedValue = try sut.decode(encodedValue, asType: Array<Int>.self)

        // Then
        XCTAssertEqual(decodedValue, testValue)
    }
}
