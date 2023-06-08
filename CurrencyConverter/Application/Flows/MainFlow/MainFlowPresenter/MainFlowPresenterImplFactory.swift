//
//  MainFlowPresenterImplFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class MainFlowPresenterImplFactory: MainFlowPresenterFactory {
    
    // MARK: - Properties
    
    private let flowModel: FlowModel
    
    private let selectCurrencyFlowPresenterFactory: SelectCurrencyFlowPresenterFactory
    
    // MARK: - Initializers
    
    public init(
        flowModel: FlowModel,
        selectCurrencyFlowPresenterFactory: SelectCurrencyFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.selectCurrencyFlowPresenterFactory = selectCurrencyFlowPresenterFactory
    }
    
    // MARK: - Methods
    
    public func make(for flowModel: FlowModel) -> MainFlowPresenter {
        
        return MainFlowPresenterImpl(
            flowModel: flowModel,
            selectCurrencyFlowPresenterFactory: selectCurrencyFlowPresenterFactory
        )
    }
}
