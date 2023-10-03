//
//  LatestRatesServiceCached.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class LatestRatesServiceCached: LatestRatesService {

    // MARK: - Types

    public struct CachedValue: Codable {

        // MARK: - Properties

        public let date: Date
        public let value: [CurrencyCode: Double]

        // MARK: - Initializers

        public init(date: Date, value: [CurrencyCode: Double]) {
            self.date = date
            self.value = value
        }
    }

    // MARK: - Properties

    private let latestRatesService: LatestRatesService
    private let timeout: TimeInterval
    private let localStorage: LocalStorage
    private let dateProvider: DateProvider

    private static let cachedValueKey = "rates"

    // MARK: - Initializers

    public init(
        latestRatesService: LatestRatesService,
        timeout: TimeInterval,
        localStorage: LocalStorage,
        dateProvider: DateProvider
    ) {

        self.timeout = timeout
        self.latestRatesService = latestRatesService
        self.localStorage = localStorage
        self.dateProvider = dateProvider
    }

    // MARK: - Methods

    public func fetch() async -> Result<[CurrencyCode: Double], LatestRatesServiceError> {

        let currentDate = dateProvider.getCurrentDate()

        let cachedDataResult = await localStorage.get(
            key: Self.cachedValueKey,
            asType: CachedValue.self
        )

        if
            case .success(let cachedData) = cachedDataResult,
            let cachedData = cachedData
        {
            let deadline = cachedData.date.addingTimeInterval(timeout)

            if currentDate < deadline {
                return .success(cachedData.value)
            }
        }

        let fetchResult = await latestRatesService.fetch()

        guard case .success(let currencies) = fetchResult else {

            if
                case .success(let cachedData) = cachedDataResult,
                let cachedData = cachedData
            {
                return .success(cachedData.value)
            }

            return .failure(.internalError)
        }

        await localStorage.put(
            key: Self.cachedValueKey,
            value: CachedValue(
                date: currentDate,
                value: currencies
            )
        )

        return .success(currencies)
    }
}
