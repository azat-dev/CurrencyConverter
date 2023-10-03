//
//  CurrencySelectionItemViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine

public struct CurrencySelectionItemViewModel: Hashable {

    // MARK: - Properties

    public let isActive: CurrentValueSubject<Bool, Never>
    public let id: CurrencyCode
    public let title: String
    public let description: String
    public let emoji: String

    // MARK: - Initializers

    public init(
        id: CurrencyCode,
        isActive: Bool,
        title: String,
        description: String,
        emoji: String
    ) {
        self.id = id
        self.isActive = .init(isActive)
        self.title = title
        self.description = description
        self.emoji = emoji
    }

    // MARK: - Methods

    public func activate() {

        guard !isActive.value else {
            return
        }

        isActive.value = true
    }

    public func deactivate() {

        guard isActive.value else {
            return
        }

        isActive.value = false
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: CurrencySelectionItemViewModel, rhs: CurrencySelectionItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
