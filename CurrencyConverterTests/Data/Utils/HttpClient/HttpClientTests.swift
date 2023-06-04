//
//  HttpClientTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation
import XCTest
import CurrencyConverter

final class HttpClientTests: XCTestCase {
    
    typealias SUT = HTTPClient
    
    func createSUT() -> SUT {
        
        let configuration = URLSessionConfiguration.ephemeral
        
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let client = HTTPClientImpl(session: session)
        
        return client
    }
    
    // MARK: - Methods
    
    func test_get__fail() async throws {
        
        // Given
        let sut = createSUT()
        let url = anyURL()

        let testResponse = URLProtocolStub.Params(
            data: nil,
            response: nil,
            error: URLError(.badServerResponse)
        )

        await URLProtocolStub.returns(testResponse) {
        
            // When
            let task = sut.get(from: url)
            
            let result = await task.result()
            
            // Then
            
            guard case .failure = result else {
                
                XCTFail("Error")
                return
            }
            
            // Must fail
        }
    }
    
    func test_get__success() async throws {
        
        // Given
        let sut = createSUT()
        let url = anyURL()
        
        let testResponse = URLProtocolStub.Params(
            data: "resultData".data(using: .utf8)!,
            response: HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            error: nil
        )
        
        await URLProtocolStub.returns(testResponse) {
        
            // When
            let task = sut.get(from: url)
            
            let result = await task.result()
            
            // Then
            
            guard case .success((let receivedData, let receivedResponse)) = result else {
                
                XCTFail("Error")
                return
            }
            
            // Must succeed
            XCTAssertEqual(receivedData, testResponse.data)
            XCTAssertEqual(receivedResponse.url, testResponse.response?.url)
            XCTAssertEqual(receivedResponse.statusCode, testResponse.response?.statusCode)
        }
    }
    
    // MARK: - Helpers
    
    private func anyURL() -> URL {
        
        return .init(string: "https://any_url.com")!
    }

}

// MARK: - Helpers

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
    
    public static func returns(_ params: Params, action: @escaping () async -> Void ) async {
        
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
