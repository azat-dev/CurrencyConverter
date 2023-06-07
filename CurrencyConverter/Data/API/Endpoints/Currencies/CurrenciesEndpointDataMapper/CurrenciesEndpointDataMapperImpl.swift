//
//  CurrenciesEndpointDataMapperImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation

public final class CurrenciesEndpointDataMapperImpl: CurrenciesEndpointDataMapper {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func map(_ data: Data) -> Result<[CurrencyCode : CurrencyTitle], CurrenciesEndpointDataMapperError> {
        
        let decoder = JSONDecoder()
        
        do {
            
            let result = try decoder.decode([CurrencyCode: CurrencyTitle].self, from: data)
            return .success(result)
            
        } catch {
            return .failure(.invalidData)
        }
    }
}
