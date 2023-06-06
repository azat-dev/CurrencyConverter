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
    
    private var items: [Currency]?
    
    private let onSelect: (CurrencyCode) -> Void
    
    private let onCancel: () -> Void
    
    private let onFailLoad: () -> Void
    
    // MARK: - Initializers
    
    public init(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    ) {
        
        self.onSelect = onSelect
        self.onCancel = onCancel
        self.onFailLoad = onFailLoad
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
    }
    
    // MARK: - Methods
    
    public func getItem(at index: Int) -> CurrencySelectionItemViewModel? {
        
        fatalError()
    }
    
    public func toggleSelection(at index: Int) {

        fatalError()
    }
    
    public func load() async {
        
        if !isLoading.value {
            isLoading.value = true
        }
        
        let listResult = await listSortedCurrenciesUseCase.list()
        
        guard case .success(let currencies) = listResult else {
            
            onFailLoad()
            return
        }
        
        items = currencies
        itemsIds.value = currencies.map { $0.code }
        isLoading.value = false
    }
}
