//
//  HTTPClientTaskMock.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import CurrencyConverter

class HTTPClientTaskMock: HTTPClientTask {
    
    // MARK: - Properties
    
    var isCanceled = false
    
    var resultWillReturn: (() async -> TaskResult)!
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Methods
    
    func cancel() {
        isCanceled = true
    }
    
    func result() async -> TaskResult {
        
        await resultWillReturn()
    }
}
