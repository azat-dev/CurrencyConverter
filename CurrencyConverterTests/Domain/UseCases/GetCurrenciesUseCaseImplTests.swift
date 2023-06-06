//
//  GetCurrenciesUseCaseImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class GetCurrenciesUseCaseImplTests: XCTestCase {
    
    typealias SUT = (
        useCase: GetCurrenciesUseCase,
        currenciesService: CurrenciesServiceMock
    )
    
    func createSUT() -> SUT {

        let currenciesService = CurrenciesServiceMock()
        
        let useCase = GetCurrenciesUseCaseImpl(currenciesService: currenciesService)
        
        return (
            useCase,
            currenciesService
        )
    }
    
    // MARK: - Methods
    
    func test_get__fail() async throws {
        
        // Given
        let sut = createSUT()
        
        sut.currenciesService.fetchWillReturn = {
            return .failure(.internalError)
        }

        // When
        let result = await sut.useCase.get(searchText: nil)
        
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
    
    func test_get__success() async throws {
        
        // Given
        let sut = createSUT()
        
        let serviceCurrencies = [
            "USD": "Dollar",
            "GBP": "Pounds"
        ]
        
        sut.currenciesService.fetchWillReturn = {
            return .success(serviceCurrencies)
        }

        // When
        let result = await sut.useCase.get(searchText: nil)
        
        // Then
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        var expectedCurrencies = [CurrencyCode: Currency]()
        
        for (code, title) in serviceCurrencies {
            
            expectedCurrencies[code] = .init(code: code, title: title)
        }
        
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
    }
    
    func test_get__success__with_search_text__by_code() async throws {
        
        // Given
        let sut = createSUT()
        
        let serviceCurrencies = [
            "USD": "Dollar",
            "GBP": "Pounds"
        ]
        
        let filteredItemCode = serviceCurrencies.keys.first!
        let searchText = filteredItemCode.lowercased()
        
        sut.currenciesService.fetchWillReturn = {
            return .success(serviceCurrencies)
        }

        // When
        let result = await sut.useCase.get(searchText: searchText)
        
        // Then
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        let expectedCurrencies = [
            filteredItemCode: Currency(
                code: filteredItemCode,
                title: serviceCurrencies[filteredItemCode]!
            )
        ]
        
        XCTAssertEqual(receivedCurrencies.count, 1)
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
    }
    
    func test_get__success__with_search_text__by_title() async throws {
        
        // Given
        let sut = createSUT()
        
        let serviceCurrencies = [
            "USD": "Dollar",
            "GBP": "Pounds"
        ]
        
        let filteredItemCode = serviceCurrencies.keys.first!
        let filteredItemTitle = serviceCurrencies[filteredItemCode]!
        let searchText = filteredItemTitle.lowercased()
        
        sut.currenciesService.fetchWillReturn = {
            return .success(serviceCurrencies)
        }

        // When
        let result = await sut.useCase.get(searchText: searchText)
        
        // Then
        guard case .success(let receivedCurrencies) = result else {
            XCTFail("Must succeed")
            return
        }
        
        let expectedCurrencies = [
            filteredItemCode: Currency(
                code: filteredItemCode,
                title: serviceCurrencies[filteredItemCode]!
            )
        ]
        
        XCTAssertEqual(receivedCurrencies.count, 1)
        XCTAssertEqual(receivedCurrencies, expectedCurrencies)
    }
    
    // MARK: - Helpers
    
    private func anyURL() -> URL {
        
        return .init(string: "https://any_url.com")!
    }

}

// MARK: - Helpers

class CurrenciesServiceMock: CurrenciesService {
    
    // MARK: - Properties
    
    var fetchCount = 0
    var fetchWillReturn: (() -> Result<[CurrencyCode : CurrencyTitle], CurrenciesServiceError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func fetch() async -> Result<[CurrencyCode : CurrencyTitle], CurrenciesServiceError> {
        
        fetchCount += 1
        return fetchWillReturn()
    }
}
