//
//  SelectCurrencyFlowModelImplFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class SelectCurrencyFlowModelImplFactory: SelectCurrencyFlowModelFactory {
    
    // MARK: - Properties
    
    private let currencySelectionViewControllerViewModelFactory: CurrencySelectionViewControllerViewModelFactory
    
    // MARK: - Initializers
    
    public init(currencySelectionViewControllerViewModelFactory: CurrencySelectionViewControllerViewModelFactory) {
        
        self.currencySelectionViewControllerViewModelFactory = currencySelectionViewControllerViewModelFactory
    }
    
    // MARK: - Methods
    
    public func make(
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
