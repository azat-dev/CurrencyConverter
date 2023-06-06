//
//  CurrencySelectionItemViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class CurrencySelectionItemViewModelTests: XCTestCase {
    
    typealias SUT = CurrencySelectionItemViewModel
    
    func createSUT(isActive: Bool) -> SUT {

        return CurrencySelectionItemViewModel(
            id: "USD",
            isActive: isActive,
            title: "USD",
            description: "Dollar"
        )
    }
    
    // MARK: - Methods
    
    func test_initial_value() async throws {
        
        // Given
        let sut1 = createSUT(isActive: true)
        
        // When
        // Init
        
        // Then
        XCTAssertTrue(sut1.isActive.value)
        
        // Given
        let sut2 = createSUT(isActive: false)
        
        // When
        // Init
        
        // Then
        XCTAssertFalse(sut2.isActive.value)
    }
    
    func test_activate() async throws {
        
        // Given
        let sut = createSUT(isActive: false)
        
        // When
        sut.activate()
        
        // Then
        XCTAssertTrue(sut.isActive.value)
    }
    
    func test_deactivate() async throws {
        
        // Given
        let sut = createSUT(isActive: true)
        
        // When
        sut.deactivate()
        
        // Then
        XCTAssertFalse(sut.isActive.value)
    }
}
