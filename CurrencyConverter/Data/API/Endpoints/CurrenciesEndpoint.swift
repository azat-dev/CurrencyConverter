//
//  CurrenciesEndpoint.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation

public enum CurrenciesEndpoint {
    
    case get
    
    // MARK: - Methods
    
    public func url(baseURL: URL) -> URL {
        
        switch self {
            
        case .get:
            
            var components = URLComponents()
            
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = "\(baseURL.path)/api/currencies.json"
            
            return components.url!
        }
    }
}
