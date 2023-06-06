//
//  ListSortedCurrenciesUseCase.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation

// MARK: - Interfaces

public enum ListSortedCurrenciesUseCaseError: Error {
    
    case internalError
}

public protocol ListSortedCurrenciesUseCase {
    
    func list() async -> Result<[Currency], ListSortedCurrenciesUseCaseError>
}
