//
//  SelectCurrencyFlowModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public final class SelectCurrencyFlowModelImpl: SelectCurrencyFlowModel {
    
    // MARK: - Properties
    
    public let currencySelectionViewControllerViewModel: CurrencySelectionViewControllerViewModel
    
    private let initialCurrency: CurrencyCode
    
    private let didSelect: (CurrencyCode) -> Void
    
    private let didCancel: () -> Void
    
    // MARK: - Initializers
    
    public init(
        initialCurrency: CurrencyCode,
        didSelect: @escaping (CurrencyCode) -> Void,
        didCancel: @escaping () -> Void,
        didFailToLoad: @escaping () -> Void,
        currencySelectionViewControllerViewModelFactory: CurrencySelectionViewControllerViewModelFactory
    ) {
        
        self.initialCurrency = initialCurrency
        self.didSelect = didSelect
        self.didCancel = didCancel
        
        currencySelectionViewControllerViewModel = currencySelectionViewControllerViewModelFactory.make(
            initialSelectedCurrency: initialCurrency,
            onSelect: didSelect,
            onCancel: didCancel,
            onFailLoad: didFailToLoad
        )
    }
    
    // MARK: - Methods
    
    public func run() async {
        fatalError()
    }
    
    public func cancel() {
        fatalError()
    }
}
