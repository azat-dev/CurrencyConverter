//
//  ListSortedCurrenciesUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation

public final class ListSortedCurrenciesCaseImpl: ListSortedCurrenciesUseCase {
    
    // MARK: - Properties
    
    private let getCurrenciesUseCase: GetCurrenciesUseCase
    
    // MARK: - Initializers
    
    public init(getCurrenciesUseCase: GetCurrenciesUseCase) {
        
        self.getCurrenciesUseCase = getCurrenciesUseCase
    }
    
    // MARK: - Methods
    
    public func list() async -> Result<[Currency], ListSortedCurrenciesUseCaseError> {
        
        fatalError()
    }
}
