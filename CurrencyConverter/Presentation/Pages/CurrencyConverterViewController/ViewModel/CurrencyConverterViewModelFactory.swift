//
//  CurrencyConverterViewModelFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol CurrencyConverterViewModelFactory {

    typealias ViewModel = CurrencyConverterViewModel

    func make(
        baseCurrency: CurrencyCode,
        didOpenCurrencySelector: @escaping (CurrencyCode) -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> ViewModel
}
