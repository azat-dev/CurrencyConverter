//
//  LatestRatesService.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public enum LatestRatesServiceError: Error {

    case internalError
}

public protocol LatestRatesService {

    func fetch() async -> Result<[CurrencyCode: Double], LatestRatesServiceError>
}
