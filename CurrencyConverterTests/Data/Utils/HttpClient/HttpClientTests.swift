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
