//
//  CurrenciesEndpointDataMapper.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation

public typealias CurrencyCode = String

public typealias CurrencyTitle = String

public enum CurrenciesEndpointDataMapperError: Error {
    
    case invalidData
}

public protocol CurrenciesEndpointDataMapper {
    
    func map(_ data: Data) -> Result<[CurrencyCode: CurrencyTitle], CurrenciesEndpointDataMapperError>
}
