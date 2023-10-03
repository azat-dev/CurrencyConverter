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
        dependencies: (
            binaryLocalStorage: BinaryLocalStorageMock,
            coder: DataCoder
        )
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
            dependencies: (
                binaryLocalStorage,
                coder
            )
        )
    }

    // MARK: - Methods

    func test_get() async throws {

        // Given
        let sut = createSUT()
        let testKey = "testKey"
        let testValue = 1

        sut.dependencies.binaryLocalStorage.getWillReturn = { _ in

            guard let encodedValue = try? sut.dependencies.coder.encode(testValue) else {
                fatalError("Can't encode value")
            }

            return .success(encodedValue)
        }

        // When
        let resultGet = await sut.storage.get(key: testKey, asType: Int.self)

        // Then
        guard case .success(testValue) = resultGet else {
            XCTFail("Must succeed")
            return
        }

        XCTAssertEqual([testKey], sut.dependencies.binaryLocalStorage.capturedGet)
    }

    func test_put() async throws {

        // Given
        let sut = createSUT()
        let testKey = "testKey"
        let testValue = 1

        sut.dependencies.binaryLocalStorage.putWillReturn = { _, _ in
            return .success(())
        }

        // When
        let resultPut = await sut.storage.put(key: testKey, value: testValue)

        // Then
        guard case .success = resultPut else {
            XCTFail("Must succeed")
            return
        }

        guard let encodedValue = try? sut.dependencies.coder.encode(testValue) else {
            fatalError("Can't encode value")
        }

        let expectedPut: [BinaryLocalStorageMock.PutData] = [
            .init(
                key: testKey,
                value: encodedValue
            )
        ]

        XCTAssertEqual(expectedPut, sut.dependencies.binaryLocalStorage.capturedPut)
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
