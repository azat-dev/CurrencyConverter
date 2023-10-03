//
//  CurrencyConverterItemViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public struct CurrencyConverterItemViewModel: Equatable {

    // MARK: - Properties

    public let id: CurrencyCode
    public let title: String
    public let description: String
    public let amount: String
    public let emoji: String

    // MARK: - Initializers

    public init(
        id: CurrencyCode,
        title: String,
        description: String,
        amount: String,
        emoji: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.amount = amount
        self.emoji = emoji
    }
}
