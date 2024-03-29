//
//  HTTPClient.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 04.06.23.
//

import Foundation

public protocol HTTPClient {

    @discardableResult
    func get(from url: URL) -> HTTPClientTask
}
