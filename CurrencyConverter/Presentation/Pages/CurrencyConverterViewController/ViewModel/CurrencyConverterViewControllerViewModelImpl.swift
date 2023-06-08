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
    
    
    public let isLoading = CurrentValueSubject<Bool, Never>(true)
    
    public var currentAmount: Double = 1
    
    public let amount = CurrentValueSubject<String, Never>("1")
    
    private var currentCurrency: CurrencyCode?
    
    public let sourceCurrency: CurrentValueSubject<Currency?, Never>
    
    public let itemsIds = CurrentValueSubject<[CurrencyCode], Never>([])
    
    
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
        
        currentCurrency = baseCurrency
        sourceCurrency = .init(nil)
    }
    
    // MARK: - Methods
    
    private func update(silent: Bool) async {
        
        currentCurrency = currentCurrency ?? baseCurrency
        
        guard let currentCurrency = currentCurrency else {
            return
        }
        
        if !silent && !isLoading.value {
            isLoading.value = true
        }
        
        async let currenciesResult = await listSortedCurrenciesUseCase.list(searchText: nil)
        
        async let ratesResult = await convertCurrencyUseCase.convert(
            amount: currentAmount,
            from: currentCurrency
        )
        
        guard case .success(let sortedCurrencies) = await currenciesResult else {
            didFailToLoad()
            return
        }
        
        itemsIds.value = sortedCurrencies.compactMap { currency in
            
            if currency.code == currentCurrency {
                return nil
            }
            
            return currency.code
        }
        
        sourceCurrency.value = sortedCurrencies.first { $0.code == currentCurrency }
        isLoading.value = false
    }
    
    public func load() async {
        
        await update(silent: false)
    }
    
    public func change(amount newAmount: Double) async {
        
        currentAmount = newAmount
        amount.value = String(currentAmount)
        
        await update(silent: true)
    }
    
    public func changeSourceCurrency() {
        
        guard let currentCurrency = currentCurrency else {
            return
        }
        
        didOpenCurrencySelector(currentCurrency)
    }
    
    public func update(selectedCurrency: CurrencyCode) async {
        
        currentCurrency = selectedCurrency
        await update(silent: true)
    }
    
    public func getItem(for id: CurrencyCode) -> CurrencyConverterViewControllerItemViewModel? {
        fatalError()
    }
}
