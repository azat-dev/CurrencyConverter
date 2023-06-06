//
//  CurrenciesServiceImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 05.06.23.
//

import Foundation

public final class CurrenciesServiceImpl: CurrenciesService {
    
    // MARK: - Properties
    
    private let baseURL: URL
    private let httpClient: HTTPClient
    private let dataMapper: CurrenciesEndpointDataMapper
    
    // MARK: - Initializers
    
    public init(
        baseURL: URL,
        httpClient: HTTPClient,
        dataMapper: CurrenciesEndpointDataMapper
    ) {
       
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.dataMapper = dataMapper
    }
    
    // MARK: - Methods
    
    public func fetch() async -> Result<[CurrencyCode : CurrencyTitle], CurrenciesServiceError> {
        
        
        let endpointURL = CurrenciesEndpoint.get.url(baseURL: baseURL)
        
        let httpResult = await httpClient.get(from: endpointURL).result()
        
        guard case .success((let data, _)) = httpResult else {
            return .failure(.internalError)
        }
        
        let mappingResult = dataMapper.map(data)
        
        guard case .success(let currencies) = mappingResult else {
            return .failure(.internalError)
        }

        return .success(currencies)
    }
}
