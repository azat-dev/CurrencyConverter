//
//  CurrencyConverterService.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public enum CurrencyConverterServiceError: Error {

    case internalError
}

public protocol CurrencyConverterService {

    func convert(
        amount: Double,
        from targetCurrency: CurrencyCode
    ) async -> Result<[CurrencyCode: Double], CurrencyConverterServiceError>
}
