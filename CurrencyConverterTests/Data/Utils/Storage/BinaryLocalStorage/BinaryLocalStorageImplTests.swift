//
//  BinaryLocalStorageImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 07.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class BinaryLocalStorageImplTests: XCTestCase {
    
    typealias SUT = BinaryLocalStorage
    
    func createSUT(
        directory: URL,
        prefix: String = ""
    ) -> SUT {
        
        
        let fileManager = FileManager.default
        
        let storage = BinaryLocalStorageImpl(
            directory: directory,
            prefix: prefix,
            fileManager: fileManager
        )
        
        return storage
    }
    
    // MARK: - Methods
    
    func test_get__not_existing() async throws {
        
        // Given
        let testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        let prefix = "someprefix"
        
        let sut = createSUT(directory: testDirectory, prefix: prefix)
        
        // When
        let result = await sut.get(key: "not_existing")
        
        // Then
        guard case .success(let receivedObject) = result else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertNil(receivedObject)
    }
    
    func test_put_get() async throws {
        
        // Given
        let testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        let prefix = "someprefix"
        let testKey = "testKey"
        let testData = "testData".data(using: .utf8)!
        let sut = createSUT(directory: testDirectory, prefix: prefix)
        
        // When
        let resultPut = await sut.put(key: testKey, value: testData)
        
        // Then
        guard case .success = resultPut else {
            XCTFail("Must succeed")
            return
        }
        
        // When
        let resultGet = await sut.get(key: testKey)
        
        // Then
        guard case .success(let receivedObject) = resultGet else {
            XCTFail("Must succeed")
            return
        }
        
        let unwrappedObject = try XCTUnwrap(receivedObject)
        XCTAssertEqual(unwrappedObject, testData)
    }
    
    func test_put_delete_get() async throws {
        
        // Given
        let testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        let prefix = "someprefix"
        let testKey = "testKey"
        let testData = "testData".data(using: .utf8)!
        let sut = createSUT(directory: testDirectory, prefix: prefix)
        
        // When
        let resultPut = await sut.put(key: testKey, value: testData)
        
        // Then
        guard case .success = resultPut else {
            XCTFail("Must succeed")
            return
        }
        
        // When
        let resultDelete = await sut.delete(key: testKey)
        
        // Then
        guard case .success = resultDelete else {
            XCTFail("Must succeed")
            return
        }
        
        // When
        let resultGet = await sut.get(key: testKey)
        
        // Then
        guard case .success(let receivedObject) = resultGet else {
            XCTFail("Must succeed")
            return
        }
        
        XCTAssertNil(receivedObject)
    }
}
