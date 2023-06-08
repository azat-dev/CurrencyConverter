//
//  SelectCurrencyFlowModelFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol SelectCurrencyFlowModelFactory {
    
    typealias FlowModel = SelectCurrencyFlowModel
    
    func make(
        initialCurrency: CurrencyCode,
        didSelect: @escaping (CurrencyCode) -> Void,
        didCancel: @escaping () -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> FlowModel
}

