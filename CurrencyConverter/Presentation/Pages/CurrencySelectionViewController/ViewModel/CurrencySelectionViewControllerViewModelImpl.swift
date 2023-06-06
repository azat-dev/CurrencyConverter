//
//  CurrencySelectionViewControllerViewModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine

public final class CurrencySelectionViewControllerViewModelImpl: CurrencySelectionViewControllerViewModel {
    
    // MARK: - Properties
    
    public var isLoading = CurrentValueSubject<Bool, Never>(true)
    
    public var itemsIds = CurrentValueSubject<[CurrencyCode], Never>([])
    
    private let listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    
    private var itemsById: [CurrencyCode: CurrencySelectionItemViewModel]?
    
    private var activeItemId: CurrencyCode?
    
    private let onSelect: (CurrencyCode) -> Void
    
    private let onCancel: () -> Void
    
    private let onFailLoad: () -> Void
    
    private var currentSearchText: String?
    
    // MARK: - Initializers
    
    public init(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    ) {
       
        self.activeItemId = initialSelectedCurrency
        self.onSelect = onSelect
        self.onCancel = onCancel
        self.onFailLoad = onFailLoad
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
    }
}

// MARK: - Output Methods

extension CurrencySelectionViewControllerViewModelImpl {
    
    public func getItem(at index: Int) -> CurrencySelectionItemViewModel? {
        
        let itemId = itemsIds.value[index]
        return itemsById?[itemId]
    }
}

// MARK: - Input Methods

extension CurrencySelectionViewControllerViewModelImpl {
    
    public func toggleSelection(at index: Int) {

        if
            let activeItemId = activeItemId,
            let prevSelectedItem = itemsById?[activeItemId]
        {
            prevSelectedItem.deactivate()
        }
        
        let newActiveItem = getItem(at: index)
        newActiveItem?.activate()
        
        activeItemId = newActiveItem?.id
    }
    
    private func load(with searchText: String?, isSilent: Bool) async {
        
        if !isLoading.value && !isSilent {
            isLoading.value = true
        }
        
        let listResult = await listSortedCurrenciesUseCase.list(searchText: searchText)
        
        guard case .success(let currencies) = listResult else {
            
            onFailLoad()
            return
        }
        
        itemsById = currencies.reduce(into: [CurrencyCode: CurrencySelectionItemViewModel]()) { partialResult, currency in
            
            let id = currency.code
            
            partialResult[id] = .init(
                id: id,
                isActive: id == activeItemId,
                title: currency.code,
                description: currency.title,
                emoji: currency.emoji
            )
        }
        
        itemsIds.value = currencies.map { $0.code }
        isLoading.value = false
    }
    
    public func load() async {
        
        await load(with: nil, isSilent: false)
    }
    
    public func filterItems(by text: String) async {
        
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        await load(
            with: cleanedText.isEmpty ? nil : cleanedText,
            isSilent: true
        )
    }
    
    public func removeFilter() async {
        
        await load(with: nil, isSilent: false)
    }
}
