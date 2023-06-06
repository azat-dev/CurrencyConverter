//
//  LocalStorageFilesTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class LocalStorageFilesTests: XCTestCase {
    
    typealias SUT = (
        storage: LocalStorage,
        binaryLocalStorage: BinaryLocalStorageMock,
        coder: DataCoder
    )
    
    func createSUT() -> SUT {
        
        let binaryLocalStorage = BinaryLocalStorageMock()
        let coder = DataCoderJSON()
        
        let storage = LocalStorageFiles(
            binaryLocalStorage: binaryLocalStorage,
            coder: coder
        )
        
        return (
            storage,
            binaryLocalStorage,
            coder
        )
    }
    
    // MARK: - Methods
    
    func test_get() async throws {
        
        // Given
        let sut = createSUT()
        let testKey = "testKey"
        let testValue = 1
        
        sut.binaryLocalStorage.getWillReturn = { _ in
            return .success(try! sut.coder.encode(testValue))
        }
        
        // When
        let resultGet = await sut.storage.get(key: testKey, as: Int.self)
        
        // Then
        guard case .success(testValue) = resultGet else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertEqual([testKey], sut.binaryLocalStorage.capturedGet)
    }
    
    func test_put() async throws {
        
        // Given
        let sut = createSUT()
        let testKey = "testKey"
        let testValue = 1
        
        sut.binaryLocalStorage.putWillReturn = { _, _ in
            return .success(())
        }
        
        // When
        let resultPut = await sut.storage.put(key: testKey, value: testValue)
        
        // Then
        guard case .success = resultPut else {
            XCTFail("Must succeed")
            return
        }
        
        let expectedPut: [BinaryLocalStorageMock.PutData] = [
            .init(
                key: testKey,
                value: try! sut.coder.encode(testValue)
            )
        ]
        
        XCTAssertEqual(expectedPut, sut.binaryLocalStorage.capturedPut)
    }
}

// MARK: - Helpers

class BinaryLocalStorageMock: BinaryLocalStorage {
    
    // MARK: - Types
    
    struct PutData: Equatable {
        
        let key: String
        let value: Data
    }
    
    // MARK: - Properties
    
    var capturedGet = [String]()
    var capturedDelete = [String]()
    var capturedPut = [PutData]()
    
    
    var getWillReturn: ((_ key: String) -> Result<Data?, Error>)!
    var putWillReturn: ((_ key: String, _ value: Data) -> Result<Void, Error>)!
    var deleteWillReturn: ((_ key: String) -> Result<Void, Error>)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func get(key: String) async -> Result<Data?, Error> {
        
        capturedGet.append(key)
        return getWillReturn(key)
    }
    
    func put(key: String, value: Data) async -> Result<Void, Error> {
        
        capturedPut.append(.init(key: key, value: value))
        return putWillReturn(key, value)
    }
    
    func delete(key: String) async -> Result<Void, Error> {
        
        capturedDelete.append(key)
        return deleteWillReturn(key)
    }
}
