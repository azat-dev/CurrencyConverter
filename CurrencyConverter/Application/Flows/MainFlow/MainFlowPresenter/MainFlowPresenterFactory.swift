//
//  MainFlowPresenterFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol MainFlowPresenterFactory {
    
    typealias FlowModel = MainFlowModel
    
    func make(for: FlowModel) -> MainFlowPresenter
}
