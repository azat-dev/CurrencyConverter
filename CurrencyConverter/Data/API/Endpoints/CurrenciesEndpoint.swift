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
            
            return baseURL
        }
    }
}
