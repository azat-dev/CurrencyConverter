//
//  SelectCurrencyFlowModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public protocol SelectCurrencyFlowModelOutput {

    var currencySelectionViewControllerViewModel: CurrencySelectionViewControllerViewModel { get }
}

public protocol SelectCurrencyFlowModelInput {

    func run() async
    
    func cancel()
}

public protocol SelectCurrencyFlowModel:
    SelectCurrencyFlowModelInput,
    SelectCurrencyFlowModelOutput {}
