//
//  CurrencySelectionViewControllerViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine

public protocol CurrencySelectionViewControllerViewModelOutput {
    
    // MARK: - Properties
    
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    
    var items: CurrentValueSubject<[CurrencySelectionItemViewModel], Never> { get }
}

public protocol CurrencySelectionViewControllerViewModelInput {
    
    func load() async
    
    func toggleSelection(at index: Int)
    
    func filterItems(by text: String) async
    
    func removeFilter() async
    
    func cancel()
    
    func dispose()
}

public protocol CurrencySelectionViewControllerViewModel:
    CurrencySelectionViewControllerViewModelOutput,
    CurrencySelectionViewControllerViewModelInput {}

