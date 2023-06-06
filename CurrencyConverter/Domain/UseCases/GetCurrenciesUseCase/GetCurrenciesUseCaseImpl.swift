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

        let serviceResult = await currenciesService.fetch()
        
        guard case .success(let currencies) = serviceResult else {
            return .failure(.internalError)
        }

        var resultCurrencies = [CurrencyCode: Currency]()
        
        for (code, title) in currencies {
            
            resultCurrencies[code] = .init(code: code, title: title)
        }
        
        return .success(resultCurrencies)
    }
}
