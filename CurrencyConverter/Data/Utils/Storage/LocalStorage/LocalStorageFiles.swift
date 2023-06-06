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
        
        do {
            
            let encodedData = try coder.encode(value)
            return await binaryLocalStorage.put(key: key, value: encodedData)
            
        } catch {
            return.failure(error)
        }
    }
    
    public func get<T>(key: String, as type: T.Type) async -> Result<T?, Error> where T: Codable {
        
        let result = await binaryLocalStorage.get(key: key)
        
        switch result {
        case .failure(let error):
            return .failure(error)
            
        case .success(let encodedData):
            
            return autoreleasepool {
                
                guard let encodedData = encodedData else {
                    return .success(nil)
                }
                
                do {
                    
                    let result = try coder.decode(encodedData, as: T.self)
                    
                    return .success(result)
                    
                } catch {
                    return .failure(error)
                }
            }
        }
    }
    
    public func delete(key: String) async -> Result<Void, Error> {
        
        return await binaryLocalStorage.delete(key: key)
    }
}
