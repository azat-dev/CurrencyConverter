//
//  CurrencyConverterViewControllerViewModelImplFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class CurrencyConverterViewControllerViewModelImplFactory: CurrencyConverterViewControllerViewModelFactory {
    
    // MARK: - Properties
    
    private let convertCurrencyUseCase: ConvertCurrencyUseCase
    private let listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    
    // MARK: - Initializers
    
    public init(
        convertCurrencyUseCase: ConvertCurrencyUseCase,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    ) {

        self.convertCurrencyUseCase = convertCurrencyUseCase
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
    }
    
    // MARK: - Methods
    
    public func make(
        baseCurrency: CurrencyCode,
        didOpenCurrencySelector: @escaping (CurrencyCode) -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> ViewModel {
        
        return CurrencyConverterViewControllerViewModelImpl(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: didOpenCurrencySelector,
            didFailToLoad: didFailToLoad,
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
    }
}
