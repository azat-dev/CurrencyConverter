//
//  CurrencyConverterViewControllerViewModelFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol CurrencyConverterViewControllerViewModelFactory {
    
    typealias ViewModel = CurrencyConverterViewControllerViewModel
    
    func make(
        baseCurrency: CurrencyCode,
        didOpenCurrencySelector: @escaping (CurrencyCode) -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> ViewModel
}
