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
        fatalError()
    }
}
