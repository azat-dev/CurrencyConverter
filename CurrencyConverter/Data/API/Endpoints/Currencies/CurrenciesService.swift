//
//  CurrenciesService.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation

public enum CurrenciesServiceError: Error {
    
    case internalError
}

public protocol CurrenciesService {
 
    func fetch() async -> Result<[CurrencyCode: CurrencyTitle], CurrenciesServiceError>
}
