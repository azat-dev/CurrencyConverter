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
    
    var amount: CurrentValueSubject<String, Never> { get }
    
    var sourceCurrency: CurrentValueSubject<Currency?, Never> { get }
    
    var itemsIds: CurrentValueSubject<[CurrencyCode], Never> { get }
    
    // MARK: - Methods
    
    func getItem(for id: CurrencyCode) -> CurrencyConverterViewControllerItemViewModel?
}

public protocol CurrencyConverterViewControllerViewModelInput {
    
    func change(amount: Double) async
    
    func changeSourceCurrency()
    
    func load() async
}

public protocol CurrencyConverterViewControllerViewModelUpdateProperties {
    
    func update(selectedCurrency: CurrencyCode) async
}

public protocol CurrencyConverterViewControllerViewModel:
    CurrencyConverterViewControllerViewModelOutput,
    CurrencyConverterViewControllerViewModelInput,
    CurrencyConverterViewControllerViewModelUpdateProperties{}
