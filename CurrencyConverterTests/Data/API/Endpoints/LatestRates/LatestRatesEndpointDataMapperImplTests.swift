//
//  LatestRatesEndpointDataMapperImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class LatestRatesEndpointDataMapperImplTests: XCTestCase {
    
    typealias SUT = LatestRatesEndpointDataMapper
    
    func createSUT() -> SUT {
        
        return LatestRatesEndpointDataMapperImpl()
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
          "disclaimer": "Usage subject to terms: https://openexchangerates.org/terms",
          "license": "https://openexchangerates.org/license",
          "timestamp": 1686175200,
          "base": "USD",
          "rates": {
            "ZMW": 19.991884,
            "ZWL": 322
          }
        }
        """.data(using: .utf8)!
        
        // When
        let result = sut.map(validJSONData)
        
        // Then

        guard case .success(let ratesData) = result else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertEqual(ratesData.count, 2)
        
        let expectedRates = [
            "ZMW": 19.991884,
            "ZWL": 322
        ]
        XCTAssertEqual(ratesData, expectedRates)
    }
}
