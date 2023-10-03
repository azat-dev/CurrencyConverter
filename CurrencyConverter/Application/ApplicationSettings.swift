//
//  ApplicationSettings.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public struct ApplicationSettings {

    // MARK: - Properties

    public let baseURL: URL
    public let appId: String
    public let cacheDirectoryName: String
    public let cacheRefreshTimeout: TimeInterval
    public let baseCurrency: String

    // MARK: - Initializers

    public init(
        baseURL: URL,
        appId: String,
        cacheDirectoryName: String,
        cacheRefreshTimeout: TimeInterval,
        baseCurrency: String
    ) {
        self.baseURL = baseURL
        self.appId = appId
        self.cacheDirectoryName = cacheDirectoryName
        self.cacheRefreshTimeout = cacheRefreshTimeout
        self.baseCurrency = baseCurrency
    }
}
