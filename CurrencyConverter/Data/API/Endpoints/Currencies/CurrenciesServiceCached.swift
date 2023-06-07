//
//  CurrenciesServiceCached.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public final class CurrenciesServiceCached: CurrenciesService {
    
    // MARK: - Properties
    
    private let currenciesService: CurrenciesService
    private let timeout: TimeInterval
    private let localStorage: LocalStorage
    private let dateProvider: DateProvider
    
    // MARK: - Initializers
    
    public init(
        currenciesService: CurrenciesService,
        timeout: TimeInterval,
        localStorage: LocalStorage,
        dateProvider: DateProvider
    ) {
     
        self.timeout = timeout
        self.currenciesService = currenciesService
        self.localStorage = localStorage
        self.dateProvider = dateProvider
    }
    
    // MARK: - Methods
    
    public func fetch() async -> Result<[CurrencyCode : CurrencyTitle], CurrenciesServiceError> {
        
        fatalError()
    }
}
