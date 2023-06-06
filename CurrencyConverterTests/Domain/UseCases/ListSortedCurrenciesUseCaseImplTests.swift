//
//  ListSortedCurrenciesUseCaseImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class ListSortedCurrenciesUseCaseImplTests: XCTestCase {
    
    typealias SUT = (
        useCase: ListSortedCurrenciesUseCase,
        getCurrenciesUseCase: GetCurrenciesUseCaseMock
    )
    
    func createSUT() -> SUT {

        let getCurrenciesUseCase = GetCurrenciesUseCaseMock()
        let useCase = ListSortedCurrenciesCaseImpl(getCurrenciesUseCase: getCurrenciesUseCase)
        
        return (
            useCase,
            getCurrenciesUseCase
        )
    }
    
    // MARK: - Methods
    
    func test_list__fail() async throws {
        
        // Given
        let sut = createSUT()
        
        sut.getCurrenciesUseCase.getWillReturn = {
            return .failure(.internalError)
        }

        sut.getCurrenciesUseCase.getWithSearchTextWillReturn = { _ in
            return .failure(.internalError)
        }
        
        // When
        let result = await sut.useCase.list(searchText: nil)
        
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
    
    func test_list__success() async throws {
        
        // Given
        let sut = createSUT()
        
        let currencies: [CurrencyCode: Currency] = [
            "USD": .init(code: "USD", title: "Dollar"),
            "GBP": .init(code: "GBP", title: "Pounds"),
            "YEN": .init(code: "YEN", title: "JAPA"),
            "AUD": .init(code: "AUD", title: "Australlian Dollar"),
        ]
        
        sut.getCurrenciesUseCase.getWillReturn = {
            return .success(currencies)
        }
        
        sut.getCurrenciesUseCase.getWithSearchTextWillReturn = { _ in
            return .success(currencies)
        }

        // When
        let result = await sut.useCase.list(searchText: nil)
        
        // Then
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        let expectedCurrencies = currencies.keys.sorted().map { code in
            return currencies[code]
        }
        
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
    }
}

// MARK: - Helpers

class GetCurrenciesUseCaseMock: GetCurrenciesUseCase {
    
    // MARK: - Properties
    
    var getCount = 0
    var getWillReturn: (() -> Result<[CurrencyCode : Currency], GetCurrenciesUseCaseError>)!
    var getWithSearchTextWillReturn: ((_ searchText: String?) -> Result<[CurrencyCode : Currency], GetCurrenciesUseCaseError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func get() async -> Result<[CurrencyCode : Currency], GetCurrenciesUseCaseError> {
        
        getCount += 1
        return getWillReturn()
    }
    
    func get(searchText: String?) async -> Result<[CurrencyCode : Currency], GetCurrenciesUseCaseError> {
        
        getCount += 1
        return getWithSearchTextWillReturn(searchText)
    }
}
