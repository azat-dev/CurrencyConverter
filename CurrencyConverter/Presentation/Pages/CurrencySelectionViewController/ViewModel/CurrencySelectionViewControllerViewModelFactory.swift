//
//  CurrencySelectionViewControllerViewModelFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol CurrencySelectionViewControllerViewModelFactory {

    typealias ViewModel = CurrencySelectionViewControllerViewModel
    
    func make(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void
    ) -> ViewModel
}
