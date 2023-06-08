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
    
    public var currentAmount: Double {
        return Double(amount.value) ?? 0
    }
    
    public let amount = CurrentValueSubject<String, Never>("")
    
    private var currentCurrency: CurrencyCode?
    
    public let sourceCurrency: CurrentValueSubject<Currency?, Never>
    
    public let changedItems = PassthroughSubject<[CurrencyCode], Never>()
    
    public let itemsIds = CurrentValueSubject<[CurrencyCode], Never>([])
    
    
    private var itemsById: [CurrencyCode: CurrencyConverterViewControllerItemViewModel]?
    
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
        
        async let conversionResult = await convertCurrencyUseCase.convert(
            amount: currentAmount,
            from: currentCurrency
        )
        
        guard
            case .success(let sortedCurrencies) = await currenciesResult,
            case .success(let convertedValues) = await conversionResult
        else {
            didFailToLoad()
            return
        }
        
        let newSourceCurrency = sortedCurrencies.first { $0.code == currentCurrency }
        
        if sourceCurrency.value != newSourceCurrency {
            sourceCurrency.value = newSourceCurrency
        }
        
        let isLoadingFirstTime = (itemsById == nil)
        
        itemsById = sortedCurrencies.reduce(
            into: [CurrencyCode: CurrencyConverterViewControllerItemViewModel]()
        ) { partialResult, currency in
            
            guard let convertedAmount = convertedValues[currency.code] else {
                return
            }
            
            partialResult[currency.code] = .init(
                id: currency.code,
                title: currency.code,
                description: currency.title,
                amount: String(format: "%.2f", convertedAmount),
                emoji: currency.emoji
            )
        }
        
        let newIds = sortedCurrencies.compactMap { currency -> String? in
            
            if itemsById?[currency.code] == nil {
                return nil
            }
            
            return currency.code
        }
        
        if itemsIds.value != newIds {
            itemsIds.value = newIds
        }
        
        if !isLoadingFirstTime {
            changedItems.send(newIds)
        }
        
        isLoading.value = false
    }
    
    public func load() async {
        
        await update(silent: false)
    }
    
    public func change(amount newAmountText: String) async {
        
        amount.value = newAmountText
        
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
        
        return itemsById?[id]
    }
}
