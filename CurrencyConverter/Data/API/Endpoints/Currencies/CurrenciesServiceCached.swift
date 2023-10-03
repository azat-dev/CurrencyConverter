//
//  CurrenciesServiceCached.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public final class CurrenciesServiceCached: CurrenciesService {

    // MARK: - Types

    public struct CachedValue: Codable {

        // MARK: - Properties

        public let date: Date
        public let value: [CurrencyCode: CurrencyTitle]

        // MARK: - Initializers

        public init(date: Date, value: [CurrencyCode: CurrencyTitle]) {
            self.date = date
            self.value = value
        }
    }

    // MARK: - Properties

    private let currenciesService: CurrenciesService
    private let timeout: TimeInterval
    private let localStorage: LocalStorage
    private let dateProvider: DateProvider

    private static let cachedValueKey = "currencies"

    // MARK: - Initializers

    public init(
        currenciesService: CurrenciesService,
        timeout: TimeInterval,
        localStorage: LocalStorage,
        dateProvider: DateProvider
    ) {

        self.timeout = timeout
        self.currenciesService = currenciesService
        self.localStorage = localStorage
        self.dateProvider = dateProvider
    }

    // MARK: - Methods

    public func fetch() async -> Result<[CurrencyCode: CurrencyTitle], CurrenciesServiceError> {

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

        let fetchResult = await currenciesService.fetch()

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
