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
        
        return await list(searchText: nil)
    }
    
    public func list(searchText: String?) async -> Result<[Currency], ListSortedCurrenciesUseCaseError> {
        
        let currenciesResult = await getCurrenciesUseCase.get(searchText: nil)
        
        guard case .success(let currenciesDict) = currenciesResult else {
            return .failure(.internalError)
        }

        let sortedCurrencies = currenciesDict.keys.sorted().compactMap { code in
            return currenciesDict[code]
        }
        
        return .success(sortedCurrencies)
    }
}
