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
    private let httpClient: HTTPClient
    private let dataMapper: LatestRatesEndpointDataMapper
    
    // MARK: - Initializers
    
    public init(
        baseURL: URL,
        httpClient: HTTPClient,
        dataMapper: LatestRatesEndpointDataMapper
    ) {
       
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.dataMapper = dataMapper
    }
    
    // MARK: - Methods
    
    public func fetch() async -> Result<[CurrencyCode : Double], LatestRatesServiceError> {
        
        fatalError()
    }
}
