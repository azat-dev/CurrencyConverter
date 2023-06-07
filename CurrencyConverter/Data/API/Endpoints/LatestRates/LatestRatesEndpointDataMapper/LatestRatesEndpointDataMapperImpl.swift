//
//  LatestRatesEndpointDataMapperImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class LatestRatesEndpointDataMapperImpl: LatestRatesEndpointDataMapper {
    
    // MARK: - Types
    
    private struct RatesData: Codable {
        
        let rates: [CurrencyCode: Double]
    }
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func map(_ data: Data) -> Result<[CurrencyCode : Double], LatestRatesEndpointDataMapperError> {
        
        let decoder = JSONDecoder()
        
        do {
            
            let result = try decoder.decode(RatesData.self, from: data)
            return .success(result.rates)
            
        } catch {
            return .failure(.invalidData)
        }
    }
}
