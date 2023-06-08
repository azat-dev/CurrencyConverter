//
//  CurrencySelectionViewControllerViewModelImplFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class CurrencySelectionViewControllerViewModelImplFactory: CurrencySelectionViewControllerViewModelFactory {
    
    // MARK: - Properties
    
    private let listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    
    // MARK: - Initializers
    
    public init(listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase) {
        
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
    }
    
    // MARK: - Methods
    
    public func make(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void
    ) -> ViewModel {
        
        return CurrencySelectionViewControllerViewModelImpl(
            initialSelectedCurrency: initialSelectedCurrency,
            onSelect: onSelect,
            onCancel: onCancel,
            onFailLoad: onFailLoad,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
    }
}
