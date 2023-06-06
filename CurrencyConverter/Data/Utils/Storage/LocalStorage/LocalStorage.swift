//
//  LocalStorage.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public protocol LocalStorageRead {
    
    func get<T: Codable>(key: String, as: T.Type) async -> Result<T?, Error>
}

public protocol LocalStorageWrite {
    
    @discardableResult
    func put<T: Codable>(key: String, value: T) async -> Result<Void, Error>
    
    @discardableResult
    func delete(key: String) async -> Result<Void, Error>    
}

public protocol LocalStorage: LocalStorageRead, LocalStorageWrite {
}
