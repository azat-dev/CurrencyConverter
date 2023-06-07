//
//  LatestRatesEndpointDataMapperImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class LatestRatesEndpointDataMapperImpl: LatestRatesEndpointDataMapper {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func map(_ data: Data) -> Result<[CurrencyCode : Double], LatestRatesEndpointDataMapperError> {
        fatalError()
    }
}
