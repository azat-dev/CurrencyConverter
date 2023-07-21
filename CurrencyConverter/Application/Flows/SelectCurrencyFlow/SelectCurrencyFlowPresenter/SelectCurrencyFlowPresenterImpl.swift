//
//  SelectCurrencyFlowPresenterImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine
import UIKit

public final class SelectCurrencyFlowPresenterImpl: SelectCurrencyFlowPresenter {
    
    public typealias FlowModel = SelectCurrencyFlowModel
    
    // MARK: - Properties
    
    private let flowModel: FlowModel
    
    // MARK: - Initializers
    
    public init(flowModel: FlowModel) {
        
        self.flowModel = flowModel
    }
    
    // MARK: - Methods
    
    public func present(at navigationController: UINavigationController) {
        
        DispatchQueue.main.async {
            
            let viewModel = self.flowModel.currencySelectionViewControllerViewModel
            let vc = CurrencySelectionViewController(viewModel: viewModel)
            
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    public func dismiss(from navigationController: UINavigationController) {
        
        DispatchQueue.main.async {
            navigationController.popViewController(animated: true)
        }
    }
}
