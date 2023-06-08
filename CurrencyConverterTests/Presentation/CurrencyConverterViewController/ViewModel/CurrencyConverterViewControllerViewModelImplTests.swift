//
//  CurrencyConverterViewControllerViewModelImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine
import XCTest

import CurrencyConverter

final class CurrencyConverterViewControllerViewModelImplTests: XCTestCase {
    
    typealias SUT = (
        viewModel: CurrencyConverterViewControllerViewModel,
        
        convertCurrencyUseCase: ConvertCurrencyUseCaseMock,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCaseMock,
        
        didOpenCurrencySelector: ValueStore<[CurrencyCode]>,
        
        didFailToLoadTimes: ValueStore<Int>,
        
        capturedIsLoadingSequence: ValueStore<[Bool]>,
        capturedItemsIdsSequence: ValueStore<[[CurrencyCode]]>,
        capturedSourceCurrencySequence: ValueStore<[CurrencyCode?]>
    )
    
    private var observers = Set<AnyCancellable>()
    
    func createSUT(baseCurrency: CurrencyCode) -> SUT {
        
        let convertCurrencyUseCase = ConvertCurrencyUseCaseMock()
        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()
        
        let didOpenCurrencySelector = ValueStore<[CurrencyCode]>([])
        
        let handleOpenCurrencySelector = { [weak didOpenCurrencySelector] currency in
            
            guard let didOpenCurrencySelector = didOpenCurrencySelector else {
                return
            }
            
            var newValues = didOpenCurrencySelector.value
            newValues.append(currency)
            
            didOpenCurrencySelector.value = newValues
        }
        
        let didFailToLoadTimes = ValueStore<Int>(0)
        
        let handleFailToLoad = { [weak didFailToLoadTimes] in
            
            guard let didFailToLoadTimes = didFailToLoadTimes else {
                return
            }
            
            didFailToLoadTimes.value += 1
        }
        
        let viewModel = CurrencyConverterViewControllerViewModelImpl(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: handleOpenCurrencySelector,
            didFailToLoad: handleFailToLoad,
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
        
        
        let capturedIsLoadingSequence = ValueStore<[Bool]>([])
        
        viewModel.isLoading.sink { isLoading in
            
            var newValues = capturedIsLoadingSequence.value
            newValues.append(isLoading)
            
            capturedIsLoadingSequence.value = newValues
            
        }.store(in: &observers)
        
        
        let capturedItemsIdsSequence = ValueStore<[[CurrencyCode]]>([])
        
        viewModel.itemsIds.sink { itemsIds in
            
            var newValues = capturedItemsIdsSequence.value
            newValues.append(itemsIds)
            
            capturedItemsIdsSequence.value = newValues
            
        }.store(in: &observers)
        
        let capturedSourceCurrencySequence = ValueStore<[CurrencyCode?]>([])
        
        viewModel.sourceCurrency.sink { currency in
            
            var newValues = capturedSourceCurrencySequence.value
            newValues.append(currency?.code)
            
            capturedSourceCurrencySequence.value = newValues
            
        }.store(in: &observers)
        
        return (
            viewModel,

            convertCurrencyUseCase,
            listSortedCurrenciesUseCase,
            
            didOpenCurrencySelector,
            didFailToLoadTimes,
            
            capturedIsLoadingSequence,
            capturedItemsIdsSequence,
            capturedSourceCurrencySequence
        )
    }
    
    // MARK: - Methods
    
    func test_load__fail() async throws {
        
        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)
        
        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .failure(.internalError)
        }
        
        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in
            return .failure(.internalError)
        }
        
        // When
        await sut.viewModel.load()
        
        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 1)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true])
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, [[]])
        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil])
    }
    
    func test_load__success() async throws {
        
        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)
        
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: ""),
        ]
        
        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }
        
        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in
            
            return .success([
                "EUR": 1,
                "GBP": 2
            ])
        }
        
        // When
        await sut.viewModel.load()
        
        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil, baseCurrency])
        
        let expectedIdsSequence = [
            [],
            ["EUR", "GBP"]
        ]
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedIdsSequence)
    }
    
    func test_changeSourceCurrency() async throws {
        
        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)
        
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: ""),
        ]
        
        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }
        
        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in
            
            return .success([
                "EUR": 1,
                "GBP": 2
            ])
        }
        
        await sut.viewModel.load()
        
        // When
        sut.viewModel.changeSourceCurrency()
        
        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [baseCurrency])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil, baseCurrency])
    }
    
    func test_updateSelectedCurrency() async throws {
        
        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)
        
        let newSelectedCurrency = "EUR"
        
        let currencies: [Currency] = [
        
            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: ""),
        ]
        
        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }
        
        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in
            
            return .success([
                "EUR": 1,
                "GBP": 2
            ])
        }
        
        await sut.viewModel.load()
        
        // When
        await sut.viewModel.update(selectedCurrency: newSelectedCurrency)
        
        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false, false])
        
        
        XCTAssertEqual(
            sut.capturedSourceCurrencySequence.value,
            [nil, baseCurrency, newSelectedCurrency]
        )
        
        let expectedIdsSequence = [
            [],
            ["EUR", "GBP"],
            ["USD", "GBP"]
        ]
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedIdsSequence)
    }
    
//    func test_changeAmount() async throws {
//
//        // Given
//        let baseCurrency = "USD"
//        let sut = createSUT(baseCurrency: baseCurrency)
//
//        let newAmount = 555
//
//        let newRates = [
//            "EUR": 1,
//            "GBP": 2
//        ]
//
//        let currencies: [Currency] = [
//
//            .init(code: "USD", title: "", emoji: ""),
//            .init(code: "EUR", title: "", emoji: ""),
//            .init(code: "GBP", title: "", emoji: ""),
//        ]
//
//        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
//            return .success(currencies)
//        }
//
//        sut.convertCurrencyUseCase.convertWillReturn = { amount, fromCurrency in
//
//            return .success([
//                "EUR": 1,
//                "GBP": 2
//            ])
//        }
//
//        // When
//        sut.viewModel.update(selectedCurrency: newSelectedCurrency)
//
//        // Then
//        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
//        XCTAssertEqual(sut.didOpenCurrencySelector.value, [baseCurrency])
//        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
//
//
//        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil, baseCurrency])
//
//        let expectedIdsSequence = [
//            [],
//            currencies.map { $0.code },
//            ["USD", "GBP"]
//        ]
//        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedIdsSequence)
//    }
}

// MARK: - Helpers

class ConvertCurrencyUseCaseMock: ConvertCurrencyUseCase {
    
    // MARK: - Properties
    
    var convertWillReturn: ((_ amount: Double, _ sourceCurrency: CurrencyCode) -> Result<[CurrencyCode : Double], ConvertCurrencyUseCaseError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func convert(amount: Double, from sourceCurrency: CurrencyCode) async -> Result<[CurrencyCode : Double], ConvertCurrencyUseCaseError> {
        
        return convertWillReturn(amount, sourceCurrency)
    }
}
