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
    
    public init() {
        fatalError()
    }
    
    // MARK: - Methods
    
    public func present(at navigationController: UINavigationController) {
        
        DispatchQueue.main.async {
            
            let vc = CurrencySelectionViewController()
            vc.viewModel = self.flowModel.currencySelectionViewControllerViewModel
            
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    public func dismiss(from navigationController: UINavigationController) {
        
        DispatchQueue.main.async {
            navigationController.popViewController(animated: true)
        }
    }
}
