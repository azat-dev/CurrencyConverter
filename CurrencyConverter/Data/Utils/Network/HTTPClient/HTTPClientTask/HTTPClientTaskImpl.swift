//
//  HTTPClientTaskImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

final class HTTPClientTaskImpl: HTTPClientTask {
    
    // MARK: - Types
    
    private struct AlreadyWaitsForResult: Error {}
    
    private struct UnexpectedValues: Error {}
    
    // MARK: - Properties
    
    var dataTask: URLSessionDataTask!
    
    private var isCompleted = false
    
    private var receivedData: Data?
    
    private var completionPromise: CheckedContinuation<Void, Never>?

    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func didComplete(data: Data?, response: URLResponse?, error: Error?) {
        
        receivedData = data
        isCompleted = true
        completionPromise?.resume()
        completionPromise = nil
    }
    
    public func cancel() {
        dataTask.cancel()
    }
    
    private func waitForResult() async {
        
        await withCheckedContinuation { continuation in
            self.completionPromise = continuation
        }
    }
    
    public func result() async -> TaskResult {
        
        guard self.completionPromise == nil else {
            return .failure(AlreadyWaitsForResult())
        }
        
        if !isCompleted {
            await waitForResult()
        }
        
        if let error = dataTask.error {
            return .failure(error)
        }
        
        guard
            let response = dataTask.response as? HTTPURLResponse,
            let data = receivedData
        else {
            return .failure(UnexpectedValues())
        }
        
        return .success((data, response))
    }
}
