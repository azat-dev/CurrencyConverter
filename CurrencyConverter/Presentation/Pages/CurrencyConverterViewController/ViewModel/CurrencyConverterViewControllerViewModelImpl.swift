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
    
    private let baseCurrency: CurrencyCode
    
    private let didOpenCurrencySelector: (CurrencyCode) -> Void
    
    private let didFailToLoad: () -> Void
    
    private let convertCurrencyUseCase: ConvertCurrencyUseCase
    
    private let listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    
    
    public var isLoading = CurrentValueSubject<Bool, Never>(true)
    
    public var amount = CurrentValueSubject<Double, Never>(1)
    
    public var sourceCurrency: CurrentValueSubject<Currency?, Never>
    
    public var itemsIds = CurrentValueSubject<[CurrencyCode], Never>([])
    
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init(
        baseCurrency: CurrencyCode,
        didOpenCurrencySelector: @escaping (CurrencyCode) -> Void,
        didFailToLoad: @escaping () -> Void,
        convertCurrencyUseCase: ConvertCurrencyUseCase,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    ) {
        
        self.baseCurrency = baseCurrency
        self.didOpenCurrencySelector = didOpenCurrencySelector
        self.didFailToLoad = didFailToLoad
        self.convertCurrencyUseCase = convertCurrencyUseCase
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
        
        sourceCurrency = .init(nil)
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
    
    public func update(selectedCurrency: CurrencyCode) {
        fatalError()
    }
}
