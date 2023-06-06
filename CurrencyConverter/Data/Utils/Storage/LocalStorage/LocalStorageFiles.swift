//
//  LocalStorageFiles.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public final class LocalStorageFiles: LocalStorage {
    
    // MARK: - Properties
    
    private let binaryLocalStorage: BinaryLocalStorage
    private let coder: DataCoder
    
    // MARK: - Methods
    
    public init(
        binaryLocalStorage: BinaryLocalStorage,
        coder: DataCoder
    ) {
        
        self.binaryLocalStorage = binaryLocalStorage
        self.coder = coder
    }
    
    public func put<T>(key: String, value: T) async -> Result<Void, Error> where T: Codable {
        
        fatalError()
    }
    
    public func get<T>(key: String, as type: T.Type) async -> Result<T?, Error> where T: Codable {
        
        fatalError()
    }
    
    public func delete(key: String) async -> Result<Void, Error> {
        
        fatalError()
    }
}
