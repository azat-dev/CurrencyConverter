//
//  DataCoder.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public protocol DataCoder {
    
    func encode<T: Codable>(_ value: T) throws -> Data
    func decode<T: Codable>(_ encodedData: Data, as: T.Type) throws -> T
}

