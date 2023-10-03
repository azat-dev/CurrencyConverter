//
//  LatestRatesEndpointDataMapperMock.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import CurrencyConverter

class LatestRatesEndpointDataMapperMock: LatestRatesEndpointDataMapper {

    // MARK: - Properties

    var willReturn: ((_ data: Data) -> Result<[CurrencyCode: Double], LatestRatesEndpointDataMapperError>)!

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func map(_ data: Data) -> Result<[CurrencyCode: Double], LatestRatesEndpointDataMapperError> {

        return willReturn(data)
    }
}
