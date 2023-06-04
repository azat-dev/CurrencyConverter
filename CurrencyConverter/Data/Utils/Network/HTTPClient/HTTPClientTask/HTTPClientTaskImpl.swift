//
//  HTTPClientTaskImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

final class HTTPClientTaskImpl: NSObject, HTTPClientTask, URLSessionDataDelegate {
    
    // MARK: - Types
    
    private struct AlreadyWaitsForResult: Error {}
    
    private struct UnexpectedValues: Error {}
    
    // MARK: - Properties
    
    private let dataTask: URLSessionDataTask
    
    private var isCompleted = false
    
    private var receivedData: Data?
    
    private var completionPromise: CheckedContinuation<Void, Never>?

    // MARK: - Initializers
    
    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    
    // MARK: - Methods
    
    public func cancel() {
        
        dataTask.cancel()
    }
    
    private func waitForResult() async {
        
        await withCheckedContinuation { continuation in
            self.completionPromise = continuation
        }
    }
    
    public func result() async -> HTTPClientTask.Result {
        
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

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if receivedData == nil {
            receivedData = Data()
        }
        
        self.receivedData?.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        isCompleted = true
        completionPromise?.resume()
        completionPromise = nil
    }
}
