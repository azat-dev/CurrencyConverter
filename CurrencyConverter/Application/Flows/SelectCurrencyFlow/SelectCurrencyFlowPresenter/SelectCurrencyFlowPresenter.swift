//
//  SelectCurrencyFlowPresenter.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

public protocol SelectCurrencyFlowPresenter {

    typealias FlowModel = SelectCurrencyFlowModel

    func present(inContainer: UINavigationController)

    func dismiss(from: UINavigationController)
}
