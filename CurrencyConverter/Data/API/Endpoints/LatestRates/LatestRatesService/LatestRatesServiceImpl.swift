//
//  LatestRatesServiceImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class LatestRatesServiceImpl: LatestRatesService {
    
    // MARK: - Properties
    
    private let baseURL: URL
    private let appId: String
    private let httpClient: HTTPClient
    private let dataMapper: LatestRatesEndpointDataMapper
    
    // MARK: - Initializers
    
    public init(
        baseURL: URL,
        appId: String,
        httpClient: HTTPClient,
        dataMapper: LatestRatesEndpointDataMapper
    ) {
       
        self.baseURL = baseURL
        self.appId = appId
        self.httpClient = httpClient
        self.dataMapper = dataMapper
    }
    
    // MARK: - Methods
    
    public func fetch() async -> Result<[CurrencyCode : Double], LatestRatesServiceError> {
        
        let endpointURL = LatestRatesEndpoint.get.url(baseURL: baseURL, appId: appId)
        
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
