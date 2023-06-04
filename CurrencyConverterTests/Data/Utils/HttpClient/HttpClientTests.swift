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
    
    func test_get__fail() throws {
        
        // Given
        let sut = createSUT()
        let url = anyURL()
        
        let expectedResponse = URLProtocolStub.Params(
            data: nil,
            response: nil,
            error: URLError(.badServerResponse)
        )
        
        let expectationToFailRequest = expectation(description: "The request must fail")
        
        // When
        URLProtocolStub.withParams(expectedResponse) {
            
            sut.get(from: url) { result in
                
                guard case .failure = result else {
                    return
                }
                
                expectationToFailRequest.fulfill()
            }
        }
        
        // Then
        // Must fail
        wait(for: [expectationToFailRequest], timeout: 1)
    }
    
    func test_get__success() throws {
        
        // Given
        let sut = createSUT()
        let url = anyURL()
        
        let expectedResponse = URLProtocolStub.Params(
            data: "resultData".data(using: .utf8)!,
            response: HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            error: nil
        )
        
        let expectation = expectation(description: "The request must succeed")
        
        // When
        URLProtocolStub.withParams(expectedResponse) {
            
            sut.get(from: url) { result in
                
                guard case .success = result else {
                    return
                }
                
                expectation.fulfill()
            }
        }
        
        // Then
        // Must succeed
        wait(for: [expectation], timeout: 1)
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
        let response: URLResponse?
        let error: Error?
    }
    
    // MARK: - Properties
    
    private static let semaphore = DispatchSemaphore(value: 1)
    
    private static var params: Params?
    
    // MARK: - Methods
    
    public static func withParams(_ newParams: Params, action: @escaping () -> Void ) {
        
        defer { semaphore.signal() }
        semaphore.wait()
        
        params = newParams
        
        action()
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        
        defer { Self.semaphore.signal() }
        Self.semaphore.wait()
        
        guard let params = Self.params else {
            return
        }
        
        if let data = params.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = params.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = params.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override public func stopLoading() {
    }
}
