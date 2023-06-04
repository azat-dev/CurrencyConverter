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
    
    func test_map__invalid_data() async throws {
        
        // Given
        let sut = createSUT()
        let invalidJSONData = "invalid_json".data(using: .utf8)!
        
        // When
        let result = sut.map(invalidJSONData)
        
        guard case .success = result else {
            return
        }
        
        // Must fail
        XCTFail("Must fail")
    }
}
