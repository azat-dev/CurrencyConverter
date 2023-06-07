//
//  CurrencyConverterServiceImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class CurrencyConverterServiceImpl: CurrencyConverterService {
    
    // MARK: - Properties
    
    private let baseCurrency: CurrencyCode
    private let latestRatesService: LatestRatesService
    
    // MARK: - Initializers
    
    public init(
        baseCurrency: CurrencyCode,
        latestRatesService: LatestRatesService
    ) {
    
        self.baseCurrency = baseCurrency
        self.latestRatesService = latestRatesService
    }
    
    // MARK: - Methods
    
    public func convert(
        amount: Double,
        from sourceCurrency: CurrencyCode
    ) async -> Result<[CurrencyCode : Double], CurrencyConverterServiceError> {
        
        let ratesResult = await latestRatesService.fetch()
        
        guard case .success(let rates) = ratesResult else {
            return .failure(.internalError)
        }

        if sourceCurrency == baseCurrency {
            return .success(rates)
        }
        
        guard let sourceCurrencyRate = rates[sourceCurrency] else {
            return .failure(.internalError)
        }
        
        var resultValues = [CurrencyCode: Double]()
        
        for (currency, rate) in rates {
            
            if currency == sourceCurrency {
                continue
            }
            
            resultValues[currency] = amount * rate / sourceCurrencyRate
        }
        
        resultValues[baseCurrency] = amount / sourceCurrencyRate
        
        return .success(resultValues)
    }
}
