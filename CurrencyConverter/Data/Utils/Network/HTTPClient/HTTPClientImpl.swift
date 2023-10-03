//
//  HTTPClientImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

public final class HTTPClientImpl: HTTPClient {

    // MARK: - Properties

    private let session: URLSession

    // MARK: - Initializers

    public init(session: URLSession) {
        self.session = session
    }

    // MARK: - Methods

    public func get(from url: URL) -> HTTPClientTask {

        let task = HTTPClientTaskImpl()

        let dataTask = session.dataTask(with: url) { data, response, error in
            task.didComplete(data: data, response: response, error: error)
        }

        task.dataTask = dataTask
        dataTask.resume()

        return task
    }
}
