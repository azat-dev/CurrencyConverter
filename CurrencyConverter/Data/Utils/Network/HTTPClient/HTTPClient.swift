//
//  HTTPClient.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

public protocol HTTPClient {
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
