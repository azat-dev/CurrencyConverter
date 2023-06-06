//
//  HTTPClientMock.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import CurrencyConverter

class HTTPClientMock: HTTPClient {
    
    // MARK: - Properties
    
    var getWillReturn: ((_ url: URL) -> HTTPClientTask)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func get(from url: URL) -> HTTPClientTask {
        return getWillReturn(url)
    }
}
