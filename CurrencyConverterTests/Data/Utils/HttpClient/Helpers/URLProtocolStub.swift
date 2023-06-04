//
//  URLProtocolStub.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

public final class URLProtocolStub: URLProtocol {

    // MARK: - Types
    
    public struct Params {

        let data: Data?
        let response: HTTPURLResponse?
        let error: Error?
    }
    
    public actor Lock {
        
        // MARK: - Initializers
        
        init() {}
        
        // MARK: - Methods
        
        func execute( _ action: @escaping() async -> Void) async {
            await action()
        }
    }
    
    // MARK: - Properties
    
    private static let lock = Lock()
    
    private static var params: Params?
    
    // MARK: - Methods
    
    public static func withGivenResponse(_ params: Params, action: @escaping () async -> Void ) async {
        
        await lock.execute {
            
            Self.params = params
            await action()
        }
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        
        Task {
         
            await Self.lock.execute {
                
                guard let params = Self.params else {
                    return
                }
                
                if let data = params.data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                
                if let response = params.response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                
                if let error = params.error {
                    self.client?.urlProtocol(self, didFailWithError: error)
                } else {
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            }
        }
    }
    
    override public func stopLoading() {
    }
}
