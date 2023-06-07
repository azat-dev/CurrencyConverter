//
//  LatestRatesEndpointDataMapper.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public enum LatestRatesEndpointDataMapperError: Error {
    
    case invalidData
}

public protocol LatestRatesEndpointDataMapper {
    
    func map(_ data: Data) -> Result<[CurrencyCode: Double], LatestRatesEndpointDataMapperError>
}
