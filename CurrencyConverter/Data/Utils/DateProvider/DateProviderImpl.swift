//
//  DateProviderImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class DateProviderImpl: DateProvider {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func getCurrentDate() -> Date {
        return Date()
    }
}
