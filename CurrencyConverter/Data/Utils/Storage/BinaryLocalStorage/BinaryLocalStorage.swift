//
//  BinaryLocalStorage.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public protocol BinaryLocalStorage {
 
    func get(key: String) async -> Result<Data?, Error>
    
    @discardableResult
    func put(key: String, value: Data) async -> Result<Void, Error>
    
    @discardableResult
    func delete(key: String) async -> Result<Void, Error>    
}
