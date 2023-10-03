//
//  ConvertCurrencyUseCase.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

// MARK: - Interfaces

public enum ConvertCurrencyUseCaseError: Error {

    case internalError
}

public protocol ConvertCurrencyUseCase {

    func convert(
        amount: Double,
        from: CurrencyCode
    ) async -> Result<[CurrencyCode: Double], ConvertCurrencyUseCaseError>
}
