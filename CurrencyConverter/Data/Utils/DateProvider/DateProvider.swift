//
//  DateProvider.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol DateProvider {

    func getCurrentDate() -> Date
}
