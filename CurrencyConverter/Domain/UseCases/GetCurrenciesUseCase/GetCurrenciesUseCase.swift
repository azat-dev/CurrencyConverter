//
//  GetCurrenciesUseCase.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation

public enum GetCurrenciesUseCaseError: Error {
    
    case internalError
}

public protocol GetCurrenciesUseCase {
    
    func get(searchText: String?) async -> Result<[CurrencyCode: Currency], GetCurrenciesUseCaseError>
}
