//
//  ConvertCurrencyUseCaseImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class ConvertCurrencyUseCaseImpl: ConvertCurrencyUseCase {
    
    // MARK: - Properties
    
    private let baseCurrency: CurrencyCode
    private let currencyConverterService: CurrencyConverterService
    
    // MARK: - Initializers
    
    public init(
        baseCurrency: CurrencyCode,
        currencyConverterService: CurrencyConverterService
    ) {
        
        self.baseCurrency = baseCurrency
        self.currencyConverterService = currencyConverterService
    }
    
    // MARK: - Methods
    
    public func convert(
        amount: Double,
        from sourceCurrency: CurrencyCode
    ) async -> Result<[CurrencyCode : Double], ConvertCurrencyUseCaseError> {
        
        let result = await currencyConverterService.convert(
            amount: amount,
            from: sourceCurrency
        )
        
        guard case .success(let values) = result else {
            return .failure(.internalError)
        }

        return .success(values)
    }
}
