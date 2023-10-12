//
//  ConvertCurrencyUseCaseMock.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 12.10.23.
//

import Foundation
import CurrencyConverter

class ConvertCurrencyUseCaseMock: ConvertCurrencyUseCase {

    // MARK: - Properties

    typealias ConvertWillReturn = Result<[CurrencyCode: Double], ConvertCurrencyUseCaseError>

    var convertWillReturn: ((_ amount: Double, _ sourceCurrency: CurrencyCode) -> ConvertWillReturn)!

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func convert(
        amount: Double,
        from sourceCurrency: CurrencyCode
    ) async -> Result<[CurrencyCode: Double], ConvertCurrencyUseCaseError> {

        return convertWillReturn(amount, sourceCurrency)
    }
}
