//
//  GetCurrenciesUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation

public final class GetCurrenciesUseCaseImpl: GetCurrenciesUseCase {
    
    // MARK: - Properties
    
    private let currenciesService: CurrenciesService
    
    // MARK: - Initializers
    
    public init(currenciesService: CurrenciesService) {
        
        self.currenciesService = currenciesService
    }
    
    // MARK: - Methods
    
    public func get() async -> Result<[CurrencyCode: Currency], GetCurrenciesUseCaseError> {
        
        return await get(searchText: nil)
    }
    
    public func get(searchText: String?) async -> Result<[CurrencyCode: Currency], GetCurrenciesUseCaseError> {

        let serviceResult = await currenciesService.fetch()
        
        guard case .success(let currencies) = serviceResult else {
            return .failure(.internalError)
        }

        var resultCurrencies = [CurrencyCode: Currency]()
        
        let cleanedSearchText = searchText?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        for (code, title) in currencies {
            
            if
                let cleanedSearchText = cleanedSearchText,
                !cleanedSearchText.isEmpty
            {
                let containsSearchText = code.lowercased().contains(cleanedSearchText) ||
                    title.lowercased().contains(cleanedSearchText)
                
                guard containsSearchText else {
                    continue
                }
            }
            
            let code = code.uppercased()
            
            resultCurrencies[code] = .init(
                code: code,
                title: title,
                emoji: currenciesEmojies[code] ?? "🏳️"
            )
        }
        
        return .success(resultCurrencies)
    }
}
