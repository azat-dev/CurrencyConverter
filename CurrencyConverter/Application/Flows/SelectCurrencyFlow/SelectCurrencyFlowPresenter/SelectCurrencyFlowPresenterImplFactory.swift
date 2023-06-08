//
//  SelectCurrencyFlowPresenterImplFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class SelectCurrencyFlowPresenterImplFactory: SelectCurrencyFlowPresenterFactory {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func make(for flowModel: FlowModel) -> SelectCurrencyFlowPresenter {
        
        return SelectCurrencyFlowPresenterImpl(flowModel: flowModel)
    }
}
