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
    
    var itemsIds: CurrentValueSubject<[CurrencyCode], Never> { get }
    
    // MARK: - Methods
    
    func getItem(at index: Int) -> CurrencySelectionItemViewModel?
}

public protocol CurrencySelectionViewControllerViewModelInput {
    
    func load() async
    
    func toggleSelection(at index: Int)
    
    func filterItems(by text: String) async
    
    func removeFilter() async
}

public protocol CurrencySelectionViewControllerViewModel:
    CurrencySelectionViewControllerViewModelOutput,
    CurrencySelectionViewControllerViewModelInput {}

