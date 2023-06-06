//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation

public struct Currency: Equatable {

    // MARK: - Properties
    
    public let code: String
    public let title: String
    
    // MARK: - Initializers
    
    public init(
        code: String,
        title: String
    ) {
        self.code = code
        self.title = title
    }
}
