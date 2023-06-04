//
//  HTTPClientTask.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

public protocol HTTPClientTask {
    
    // MARK: - Types
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    // MARK: - Methods
    
    func cancel()
    
    func result() async -> Result
}
