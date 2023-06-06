//
//  BinaryLocalStorageImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation

public final class BinaryLocalStorageImpl: BinaryLocalStorage {
    
    // MARK: - Properties
    
    private let directory: URL
    private let prefix: String
    private let fileManager: FileManager

    // MARK: - Methods
    
    public init(
        directory: URL,
        prefix: String = "",
        fileManager: FileManager = FileManager.default
    ) {
        
        self.directory = directory
        self.prefix = prefix
        self.fileManager = fileManager
    }
    
    public func put(key: String, value data: Data) async -> Result<Void, Error> {
        fatalError()
    }
    
    public func get(key: String) async -> Result<Data?, Error> {
        
        fatalError()
    }
    
    public func delete(key: String) async -> Result<Void, Error> {
        
        fatalError()
    }
    
    public func listKeys() async -> Result<[String], Error> {
        
        fatalError()
    }
    
    public func deleteAll() async -> Result<Void, Error> {
        
        fatalError()
    }
    
    public func deleteAll(where predicate: (String) -> Bool) async -> Result<Void, Error> {
        
        fatalError()
    }
    
    private func getFileName(forKey key: String) throws -> URL {
        
        guard let cleanedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            throw NSError(domain: "Can't encode file name", code: 0)
        }
        
        return directory.appendingPathComponent(prefix + cleanedKey).appendingPathExtension("json")
    }
}
