//
//  CurrencyConverterViewControllerViewModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public final class CurrencyConverterViewControllerViewModelImpl: CurrencyConverterViewControllerViewModel {
    
    // MARK: - Properties
    
    public var isLoading = CurrentValueSubject<Bool, Never>(true)
    
    public var amount = CurrentValueSubject<Double, Never>(1)
    
    public var sourceCurrency: CurrentValueSubject<CurrencyCode, Never>
    
    public var itemsIds = CurrentValueSubject<[CurrencyCode], Never>([])
    
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init(baseCurrency: CurrencyCode) {
        
        sourceCurrency = .init(baseCurrency)
    }
    
    // MARK: - Methods
    
    public func load() async {
        fatalError()
    }
    
    public func change(amount: Double) {
        fatalError()
    }
    
    public func changeSourceCurrency() {
        fatalError()
    }
}
