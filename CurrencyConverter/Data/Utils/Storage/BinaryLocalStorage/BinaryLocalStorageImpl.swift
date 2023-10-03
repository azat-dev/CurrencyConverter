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

        do {

            let fileURL = try getFileName(forKey: key)
            let directoryUrl = fileURL.deletingLastPathComponent()

            if !fileManager.fileExists(atPath: directoryUrl.path) {

                try fileManager.createDirectory(
                    at: directoryUrl,
                    withIntermediateDirectories: true
                )
            }

            if !fileManager.fileExists(atPath: fileURL.path) {
                fileManager.createFile(atPath: fileURL.path, contents: data)
            } else {
                try data.write(to: fileURL, options: .atomic)
            }

            return .success(())

        } catch {
            return.failure(error)
        }
    }

    public func get(key: String) async -> Result<Data?, Error> {

        do {

            let fileURL = try getFileName(forKey: key)

            guard fileManager.fileExists(atPath: fileURL.path) else {
                return .success(nil)
            }

            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return .success(data)

        } catch {
            return .failure(error)
        }
    }

    public func delete(key: String) async -> Result<Void, Error> {

        do {

            let fileURL = try getFileName(forKey: key)

            guard fileManager.fileExists(atPath: fileURL.path) else {
                return .success(())
            }

            try fileManager.removeItem(at: fileURL)

        } catch {
            return .failure(error)
        }

        return .success(())
    }

    private func getFileName(forKey key: String) throws -> URL {

        guard let cleanedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            throw NSError(domain: "Can't encode file name", code: 0)
        }

        return directory.appendingPathComponent(prefix + cleanedKey).appendingPathExtension("json")
    }
}
