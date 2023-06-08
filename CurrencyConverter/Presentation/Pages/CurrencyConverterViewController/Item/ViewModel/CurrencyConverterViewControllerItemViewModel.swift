//
//  CurrencyConverterViewControllerItemViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public struct CurrencyConverterViewControllerItemViewModel: Equatable {
    
    // MARK: - Properties
    
    public let id: CurrencyCode
    public let title: String
    public let description: String
    public let amount: String
    
    // MARK: - Initializers
    
    public init(
        id: CurrencyCode,
        title: String,
        description: String,
        amount: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.amount = amount
    }
}
