//
//  CurrencySelectionViewControllerViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine
import XCTest

import CurrencyConverter

final class CurrencySelectionViewControllerViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: CurrencySelectionViewControllerViewModel,
        didSelectedCurrencies: ValueStore<[CurrencyCode]>,
        didCancelTimes: ValueStore<Int>,
        didFailLoadTimes: ValueStore<Int>,
        capturedIsLoadingSequence: ValueStore<[Bool]>,
        capturedItemsIdsSequence: ValueStore<[[CurrencyCode]]>,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCaseMock
    )
    
    private var observers = Set<AnyCancellable>()
    
    func createSUT(initialSelectedCurrency: CurrencyCode?) -> SUT {
        
        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()

        let capturedIsLoadingSequence = ValueStore<[Bool]>([])
        let capturedItemsIdsSequence = ValueStore<[[CurrencyCode]]>([])
        
        let didSelectedCurrencies = ValueStore([CurrencyCode]())
        let didCancelTimes = ValueStore<Int>(0)
        let didFailLoadTimes = ValueStore<Int>(0)
        
        let viewModel = CurrencySelectionViewControllerViewModelImpl(
            initialSelectedCurrency: initialSelectedCurrency,
            onSelect: { [weak didSelectedCurrencies] currency in
                
                guard let didSelectedCurrencies = didSelectedCurrencies else {
                    return
                }
                
                var newValues = didSelectedCurrencies.value
                newValues.append(currency)
                
                didSelectedCurrencies.value = newValues
            },
            onCancel: { [weak didCancelTimes] in
                
                guard let didCancelTimes = didCancelTimes else {
                    return
                }
                
                didCancelTimes.value += 1
            },
            onFailLoad: { [weak didFailLoadTimes] in
                
                guard let didFailLoadTimes = didFailLoadTimes else {
                    return
                }
                
                didFailLoadTimes.value += 1
            },
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
        
        viewModel.isLoading.sink { [weak self] isLoading in
            
            var newValues = capturedIsLoadingSequence.value
            newValues.append(isLoading)

            capturedIsLoadingSequence.value = newValues
            
        }.store(in: &observers)
        
        viewModel.itemsIds.sink { [weak self] itemsIds in
            
            var newValues = capturedItemsIdsSequence.value
            newValues.append(itemsIds)

            capturedItemsIdsSequence.value = newValues
            
        }.store(in: &observers)
        
        return (
            viewModel,
            didSelectedCurrencies,
            didCancelTimes,
            didFailLoadTimes,
            capturedIsLoadingSequence,
            capturedItemsIdsSequence,
            listSortedCurrenciesUseCase
        )
    }
    
    // MARK: - Methods
    
    func test_load__fail() async throws {
        
        // Given
        let initialSelectedCurrency = "USD"
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)
        
        sut.listSortedCurrenciesUseCase.listWillReturn = .failure(.internalError)
        
        // When
        await sut.viewModel.load()
        
        // Then
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true])
        XCTAssertEqual(sut.didFailLoadTimes.value, 1)
        XCTAssertEqual(sut.didSelectedCurrencies.value, [])
        XCTAssertEqual(sut.didCancelTimes.value, 0)
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, [])
    }
    
    func test_load__success() async throws {
        
        // Given
        
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "Dollar"),
            .init(code: "GBP", title: "Pounds"),
        ]
        
        let initialSelectedCurrency = "USD"
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)
        
        sut.listSortedCurrenciesUseCase.listWillReturn = .success(currencies)
        
        // When
        await sut.viewModel.load()
        
        // Then
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
        XCTAssertEqual(sut.didFailLoadTimes.value, 0)
        XCTAssertEqual(sut.didSelectedCurrencies.value, [])
        XCTAssertEqual(sut.didCancelTimes.value, 0)
        
        let expecteItemsIdsSequence = [
            [],
            currencies.map { $0.code }
        ]
        
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expecteItemsIdsSequence)
    }
}

// MARK: - Helpers

class ValueStore<T> {
    
    // MARK: - Properties
    
    var value: T
    
    // MARK: - Initializers
    
    init(_ value: T) {
        self.value = value
    }
}

class ListSortedCurrenciesUseCaseMock: ListSortedCurrenciesUseCase {
    
    // MARK: - Properties
    
    var listWillReturn: (Result<[Currency], ListSortedCurrenciesUseCaseError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func list() async -> Result<[Currency], ListSortedCurrenciesUseCaseError> {
        
        return listWillReturn
    }
}
