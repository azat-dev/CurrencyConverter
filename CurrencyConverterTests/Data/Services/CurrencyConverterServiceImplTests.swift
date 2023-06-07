//
//  CurrencyConverterServiceImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class CurrencyConverterServiceImplTests: XCTestCase {
    
    typealias SUT = (
        service: CurrencyConverterService,
        latestRatesService: LatestRatesServiceMock
    )
    
    func createSUT(baseCurrency: CurrencyCode) -> SUT {

        let latestRatesService = LatestRatesServiceMock()
        
        let service = CurrencyConverterServiceImpl(
            baseCurrency: baseCurrency,
            latestRatesService: latestRatesService
        )
        
        return (
            service,
            latestRatesService
        )
    }
    
    // MARK: - Methods
    
    func test_convert__fail() async throws {
        
        // Given
        let baseCurrency = "USD"
        let sourceCurrency = "JPN"
        
        let sut = createSUT(baseCurrency: baseCurrency)
        
        sut.latestRatesService.fetchWillReturn = {
            return .failure(.internalError)
        }
        
        let amount = 10.0

        // When
        let result = await sut.service.convert(
            amount: amount,
            from: sourceCurrency
        )
        
        // Then
        guard case .failure(let error) = result else {
            XCTFail("Must fail")
            return
        }
        
        guard case .internalError = error else {
            XCTFail("Wrong error type")
            return
        }
    }
    
    func test_convert__success__source_equals_to_base_currency() async throws {
        
        // Given
        let baseCurrency = "USD"
        
        let amount = 10.0
        let sourceCurrency = baseCurrency
        
        let targetCurrencyRate = 2.5
        let targetCurrency = "GBP"
        
        let sut = createSUT(baseCurrency: baseCurrency)
        
        sut.latestRatesService.fetchWillReturn = {
            return .success(
                [
                    targetCurrency: targetCurrencyRate
                ]
            )
        }

        // When
        let result = await sut.service.convert(
            amount: amount,
            from: sourceCurrency
        )
        
        // Then
        guard case .success(let convertedRates) = result else {
            XCTFail("Must succeed")
            return
        }
        
        let expectedResult = [targetCurrency: targetCurrencyRate]
        XCTAssertEqual(convertedRates, expectedResult)
    }
    
    func test_convert__success__source_currency_is_not_base_currency() async throws {
        
        // Given
        let baseCurrency = "baseCurrency"
        
        let sourceCurrency = "sourceCurrency"
        let sourceCurrencyRate = 1.2
        
        let secondCurrency = "secondCurrency"
        let secondCurrencyRate = 3.4
        
        let amount = 10.0
        
        let rates = [
            sourceCurrency: sourceCurrencyRate,
            secondCurrency: secondCurrencyRate
        ]
        
        let sut = createSUT(baseCurrency: baseCurrency)
        
        sut.latestRatesService.fetchWillReturn = {
            return .success(rates)
        }

        // When
        let result = await sut.service.convert(
            amount: amount,
            from: sourceCurrency
        )
        
        // Then
        guard case .success(let convertedValues) = result else {
            XCTFail("Must succeed")
            return
        }
        
        let expectedResult = [
            baseCurrency: amount / sourceCurrencyRate,
            secondCurrency: amount * secondCurrencyRate / sourceCurrencyRate
        ]
        
        XCTAssertEqual(convertedValues, expectedResult)
    }    
}

// MARK: - Helpers

class LatestRatesServiceMock: LatestRatesService {
    
    // MARK: - Properties
    
    var fetchCount = 0
    var fetchWillReturn: (() -> Result<[CurrencyCode : Double], LatestRatesServiceError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func fetch() async -> Result<[CurrencyCode : Double], LatestRatesServiceError> {
        
        fetchCount += 1
        return fetchWillReturn()
    }
}
