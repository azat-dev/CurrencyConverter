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
    
    // MARK: - Initializers
    
    public init(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    ) {
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
    }
    
    // MARK: - Methods
    
    public func getItem(at index: Int) -> CurrencySelectionItemViewModel? {
        
        fatalError()
    }
    
    public func toggleSelection(at index: Int) {

        fatalError()
    }
    
    public func load() {
        
        fatalError()
    }
}
