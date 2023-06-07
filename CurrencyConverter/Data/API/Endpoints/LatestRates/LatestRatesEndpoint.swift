//
//  LatestRatesEndpoint.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public enum LatestRatesEndpoint {
    
    case get
    
    // MARK: - Methods
    
    public func url(baseURL: URL, appId: String) -> URL {
        
        switch self {
            
        case .get:
            
            var components = URLComponents()
            
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = "\(baseURL.path)/api/latest.json"
            
            components.queryItems = [
                .init(
                    name: "app_id",
                    value: appId
                )
            ]
            
            return components.url!
        }
    }
}
