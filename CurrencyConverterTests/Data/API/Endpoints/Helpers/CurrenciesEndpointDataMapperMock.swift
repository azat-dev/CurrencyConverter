//
//  CurrenciesEndpointDataMapperMock.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import CurrencyConverter

class CurrenciesEndpointDataMapperMock: CurrenciesEndpointDataMapper {
    
    // MARK: - Properties
    
    var willReturn: ((_ data: Data) -> Result<[CurrencyCode : CurrencyTitle], CurrenciesEndpointDataMapperError>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func map(_ data: Data) -> Result<[CurrencyCode : CurrencyTitle], CurrenciesEndpointDataMapperError> {
        
        return willReturn(data)
    }
}
