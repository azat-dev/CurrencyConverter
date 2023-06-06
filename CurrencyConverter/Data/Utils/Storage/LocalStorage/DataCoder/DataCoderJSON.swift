//
//  DataCoderJSON.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public final class DataCoderJSON: DataCoder {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func encode<T: Codable>(_ value: T) throws -> Data {
        
        fatalError()
    }
    
    public func decode<T: Codable>(_ encodedData: Data, as: T.Type) throws -> T where T : Decodable, T : Encodable {
        
        fatalError()
    }
}
