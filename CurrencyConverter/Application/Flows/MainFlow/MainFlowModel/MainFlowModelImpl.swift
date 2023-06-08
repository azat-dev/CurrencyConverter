//
//  MainFlowModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public final class MainFlowModelImpl: MainFlowModel {
    
    public typealias UsedFactories = (
        selectCurrencyFlowModel: SelectCurrencyFlowModelFactory,
        currencyConverterViewControllerViewModel: CurrencyConverterViewControllerViewModelFactory
    )
    
    // MARK: - Properties
    
    public let currencyConverterViewControllerViewModel: CurrencyConverterViewControllerViewModel
    
    public let selectCurrencyFlowModel = CurrentValueSubject<SelectCurrencyFlowModel?, Never>(nil)
    
    private let factories: UsedFactories
    
    // MARK: - Initializers
    
    public init(
        baseCurrency: CurrencyCode,
        usedFactories: UsedFactories
    ) {
        
        currencyConverterViewControllerViewModel = usedFactories.currencyConverterViewControllerViewModel.make(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: { currency in
                fatalError()
            },
            didFailToLoad: {
                
            }
        )
        self.factories = usedFactories
    }
    
    // MARK: - Methods
    
}
