//
//  CurrencySelectionViewModelFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol CurrencySelectionViewModelFactory {

    typealias ViewModel = CurrencySelectionViewModel

    func make(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void,
        onDispose: @escaping () -> Void
    ) -> ViewModel
}
