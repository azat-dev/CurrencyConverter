//
//  CurrencyConverterViewControllerViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public protocol CurrencyConverterViewControllerViewModelOutput {
    
    // MARK: - Properties
    
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    
    var amount: CurrentValueSubject<Double, Never> { get }
    
    var sourceCurrency: CurrentValueSubject<Currency?, Never> { get }
    
    var itemsIds: CurrentValueSubject<[CurrencyCode], Never> { get }
}

public protocol CurrencyConverterViewControllerViewModelInput {
    
    func change(amount: Double)
    
    func changeSourceCurrency()
    
    func load() async
}

public protocol CurrencyConverterViewControllerViewModelUpdateProperties {
    
    func update(selectedCurrency: CurrencyCode)
}

public protocol CurrencyConverterViewControllerViewModel:
    CurrencyConverterViewControllerViewModelOutput,
    CurrencyConverterViewControllerViewModelInput,
    CurrencyConverterViewControllerViewModelUpdateProperties{}
