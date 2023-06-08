//
//  MainFlowModelImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

import XCTest
import CurrencyConverter

final class MainFlowModelImplTests: XCTestCase {
    
    typealias SUT = (
        flowModel: MainFlowModel,
        currencyConverterViewControllerViewModelFactory: CurrencyConverterViewControllerViewModelFactoryMock,
        selectCurrencyFlowModelFactory: SelectCurrencyFlowModelFactoryMock
    )
    
    func createSUT(baseCurrency: CurrencyCode) -> SUT {
        
        let currencyConverterViewControllerViewModelFactory = CurrencyConverterViewControllerViewModelFactoryMock()
        
        let selectCurrencyFlowModelFactory = SelectCurrencyFlowModelFactoryMock()
        
        let flowModel = MainFlowModelImpl(
            baseCurrency: baseCurrency,
            usedFactories: (
                selectCurrencyFlowModel: selectCurrencyFlowModelFactory,
                currencyConverterViewControllerViewModel: currencyConverterViewControllerViewModelFactory
            )
        )
        
        return (
            flowModel,
            currencyConverterViewControllerViewModelFactory,
            selectCurrencyFlowModelFactory
        )
    }
    
    // MARK: - Methods
    
    func test_select() async throws {
        
        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)
        
        sut.currencyConverterViewControllerViewModelFactory.willUseCurrencies = [
            .init(code: "USD", title: "", emoji: "")
        ]
        
        await sut.flowModel.currencyConverterViewControllerViewModel.load()
        
        // When
        sut.flowModel.currencyConverterViewControllerViewModel.changeSourceCurrency()
        
        
        // Then
        XCTAssertNotNil(sut.flowModel.selectCurrencyFlowModel.value)
    }
    
}

// MARK: - Helpers

class CurrencyConverterViewControllerViewModelFactoryMock: CurrencyConverterViewControllerViewModelFactory {
    
    // MARK: - Properties
    
    var willUseCurrencies: [Currency]!
    
    var willUseConvertionRates: [CurrencyCode : Double]?
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func make(
        baseCurrency: CurrencyCode,
        didOpenCurrencySelector: @escaping (CurrencyCode) -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> ViewModel {
        
        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()
        
        listSortedCurrenciesUseCase.listWillReturn = { [weak self] _ in
            
            guard let self = self else {
                return .failure(.internalError)
            }
            
            return .success(willUseCurrencies)
        }
        
        let convertCurrencyUseCase = ConvertCurrencyUseCaseMock()
        
        convertCurrencyUseCase.convertWillReturn = { [weak self] _, _ in
            
            guard let self = self else {
                return .failure(.internalError)
            }
            
            guard let willUseConvertionRates = willUseConvertionRates else {
                return .failure(.internalError)
            }
            
            return .success(willUseConvertionRates)
        }
        
        return CurrencyConverterViewControllerViewModelImpl(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: didOpenCurrencySelector,
            didFailToLoad: didFailToLoad,
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
    }
}

class SelectCurrencyFlowModelFactoryMock: SelectCurrencyFlowModelFactory {
    
    // MARK: - Properties
    
    let currencySelectionViewControllerViewModelFactory = CurrencySelectionViewControllerViewModelFactoryMock()
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func make(
        initialCurrency: CurrencyCode,
        didSelect: @escaping (CurrencyCode) -> Void,
        didCancel: @escaping () -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> FlowModel {
        
        return SelectCurrencyFlowModelImpl(
            initialCurrency: initialCurrency,
            didSelect: didSelect,
            didCancel: didCancel,
            didFailToLoad: didFailToLoad,
            currencySelectionViewControllerViewModelFactory: currencySelectionViewControllerViewModelFactory
        )
    }
}
