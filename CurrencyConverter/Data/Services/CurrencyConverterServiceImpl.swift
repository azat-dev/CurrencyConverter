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
        from targetCurrency: CurrencyCode
    ) async -> Result<[CurrencyCode : Double], CurrencyConverterServiceError> {
        
        fatalError()
    }
}
