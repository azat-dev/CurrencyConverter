//
//  HTTPClientTaskTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation
import XCTest
@testable import CurrencyConverter

final class HTTPClientTaskTests: XCTestCase {
    
    typealias SUT = HTTPClientTask
    
    func createSUT(url: URL) -> SUT {
        
        let configuration = URLSessionConfiguration.ephemeral
        
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: url)
        let task = HTTPClientTaskImpl(dataTask: dataTask)
        
        return task
    }
    
    // MARK: - Methods
    
    func test_result__fail() async throws {
        
        // Given
        let url = anyURL()
        let sut = createSUT(url: url)

        let testResponse = URLProtocolStub.Params(
            data: nil,
            response: nil,
            error: URLError(.badServerResponse)
        )

        await URLProtocolStub.returns(testResponse) {
        
            // When
            let result = await sut.result()
            
            // Then
            guard case .failure = result else {
                XCTFail("Error")
                return
            }
            
            // Must fail
            XCTFail()
        }
    }
    
    func test_result__success() async throws {
        
        // Given
        let url = anyURL()
        let sut = createSUT(url: url)
        
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
            let result = await sut.result()
            
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
