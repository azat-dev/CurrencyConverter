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
    public let code: String
    public let title: String
    
    // MARK: - Initializers
    
    public init(
        isActive: Bool,
        code: String,
        title: String
    ) {
        self.isActive = .init(isActive)
        self.code = code
        self.title = title
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
