//
//  SelectCurrencyFlowModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public protocol SelectCurrencyFlowModelOutput {

    var currencySelectionViewControllerViewModel: CurrencySelectionViewModel { get }
}

public protocol SelectCurrencyFlowModelInput {

    func cancel()
}

public protocol SelectCurrencyFlowModel:
    SelectCurrencyFlowModelInput,
    SelectCurrencyFlowModelOutput {}
