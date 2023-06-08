//
//  MainFlowModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public protocol MainFlowModelOutput {
    
    var currencyConverterViewControllerViewModel: CurrencyConverterViewControllerViewModel { get }
    
    var selectCurrencyFlowModel: CurrentValueSubject<SelectCurrencyFlowModel?, Never> { get }
}

public protocol MainFlowModelInput {
    
}

public protocol MainFlowModel: MainFlowModelInput, MainFlowModelOutput {}
