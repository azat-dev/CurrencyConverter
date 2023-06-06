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
        
        viewModel.isLoading.sink { isLoading in
            
            var newValues = capturedIsLoadingSequence.value
            newValues.append(isLoading)

            capturedIsLoadingSequence.value = newValues
            
        }.store(in: &observers)
        
        viewModel.itemsIds.sink { itemsIds in
            
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
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, [[]])
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
    
    func test_initial_active_item() async throws {
        
        // Given
        
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "Dollar"),
            .init(code: "GBP", title: "Pounds"),
            .init(code: "YEN", title: "Japan Yen"),
        ]
        
        let initialSelecteItemIndex = 1
        
        let initialSelectedCurrency = currencies[initialSelecteItemIndex].code
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)
        
        sut.listSortedCurrenciesUseCase.listWillReturn = .success(currencies)
        await sut.viewModel.load()
        
        // When
        // Init
        
        // Then
        
        let expectedIsActiveFlags = currencies.indices.map { index in initialSelecteItemIndex == index}
        let receivedActiveFlags = currencies.indices.map { index in sut.viewModel.getItem(at: index)?.isActive.value }
        
        XCTAssertEqual(receivedActiveFlags, expectedIsActiveFlags)
    }
    
    func test_toggle_selection__has_initial_item() async throws {
        
        // Given
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "Dollar"),
            .init(code: "GBP", title: "Pounds"),
            .init(code: "YEN", title: "Japan Yen"),
        ]
        
        let initialSelecteItemIndex = 1
        let newSelectedItemIndex = 2
        
        let initialSelectedCurrency = currencies[initialSelecteItemIndex].code
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)
        
        sut.listSortedCurrenciesUseCase.listWillReturn = .success(currencies)
        await sut.viewModel.load()
        
        // When
        sut.viewModel.toggleSelection(at: newSelectedItemIndex)
        
        // Then
        
        let expectedIsActiveFlags = currencies.indices.map { index in newSelectedItemIndex == index}
        let receivedActiveFlags = sut.viewModel.itemsIds.value.indices.map { index in sut.viewModel.getItem(at: index)?.isActive.value }
        
        XCTAssertEqual(receivedActiveFlags, expectedIsActiveFlags)
    }
    
    func test_toggle_selection__doesnt_have_initial_item() async throws {
        
        // Given
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "Dollar"),
            .init(code: "GBP", title: "Pounds"),
            .init(code: "YEN", title: "Japan Yen"),
        ]
        
        let newSelectedItemIndex = 2
        
        let sut = createSUT(initialSelectedCurrency: nil)
        
        sut.listSortedCurrenciesUseCase.listWillReturn = .success(currencies)
        await sut.viewModel.load()
        
        // When
        sut.viewModel.toggleSelection(at: newSelectedItemIndex)
        
        // Then
        let expectedIsActiveFlags = currencies.indices.map { index in newSelectedItemIndex == index}
        let receivedActiveFlags = sut.viewModel.itemsIds.value.indices.map { index in sut.viewModel.getItem(at: index)?.isActive.value }
        
        XCTAssertEqual(receivedActiveFlags, expectedIsActiveFlags)
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
