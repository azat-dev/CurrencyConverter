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
    
    var itemsIds: CurrentValueSubject<[CurrencyCode], Never> { get }
    
    // MARK: - Methods
    
    func getItem(at index: Int) -> CurrencySelectionItemViewModel?
}

