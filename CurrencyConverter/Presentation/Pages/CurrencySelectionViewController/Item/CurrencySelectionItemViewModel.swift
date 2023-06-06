//
//  CurrencySelectionItemViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine

public struct CurrencySelectionItemViewModel {

    // MARK: - Properties
    
    public let isActive: CurrentValueSubject<Bool, Never>
    public let id: CurrencyCode
    public let title: String
    public let description: String
    
    // MARK: - Initializers
    
    public init(
        id: CurrencyCode,
        isActive: Bool,
        title: String,
        description: String
    ) {
        self.id = id
        self.isActive = .init(isActive)
        self.title = title
        self.description = description
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
}
