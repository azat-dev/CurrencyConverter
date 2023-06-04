//
//  HTTPClientImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

extension URLSessionDataTask: HTTPClientTask {}

public final class HTTPClientImpl: HTTPClient {
    
    // MARK: - Types
    
    private struct UnexpectedValue: Error {}
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initializers
    
    public init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Methods
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse
            else {
                
                let error = UnexpectedValue()
                completion(.failure(error))
                return
            }
            
            completion(.success((data, response)))
        }
        
        task.resume()
        return task
    }
}
