//
//  SelectCurrencyFlowPresenterFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public protocol SelectCurrencyFlowPresenterFactory {

    typealias FlowModel = SelectCurrencyFlowModel

    func make(for: FlowModel) -> SelectCurrencyFlowPresenter
}
