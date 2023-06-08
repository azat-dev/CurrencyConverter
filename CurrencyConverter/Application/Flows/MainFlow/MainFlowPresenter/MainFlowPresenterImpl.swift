//
//  MainFlowPresenterImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine
import UIKit

public final class MainFlowPresenterImpl: MainFlowPresenter {
    
    public typealias FlowModel = MainFlowModel
    
    // MARK: - Properties
    
    private let flowModel: FlowModel
    
    private let selectCurrencyFlowPresenterFactory: SelectCurrencyFlowPresenterFactory
    
    private var observers = Set<AnyCancellable>()
    
    private var currentSelectCurrencyPresenter: SelectCurrencyFlowPresenter?
    
    // MARK: - Initializers
    
    public init(
        flowModel: FlowModel,
        selectCurrencyFlowPresenterFactory: SelectCurrencyFlowPresenterFactory
    ) {
        
        self.flowModel = flowModel
        self.selectCurrencyFlowPresenterFactory = selectCurrencyFlowPresenterFactory
    }
    
    deinit {
        observers.removeAll()
        currentSelectCurrencyPresenter = nil
    }
    
    // MARK: - Methods
    
    private func update(
        selectCurrencyFlowModel: SelectCurrencyFlowModel?,
        at navigationController: UINavigationController
    ) {
        
        guard let selectCurrencyFlowModel = selectCurrencyFlowModel else {
            
            currentSelectCurrencyPresenter?.dismiss(from: navigationController)
            return
        }
        
        let selectCurrencyFlowPresenter = selectCurrencyFlowPresenterFactory.make(for: selectCurrencyFlowModel)
        self.currentSelectCurrencyPresenter = selectCurrencyFlowPresenter
        
        selectCurrencyFlowPresenter.present(at: navigationController)
    }
    
    public func present(at window: UIWindow) {
        
        let rootNavigationController = RootNavigationController()
        
        let vc = CurrencyConverterViewController()
        vc.viewModel = flowModel.currencyConverterViewControllerViewModel
        
        rootNavigationController.pushViewController(vc, animated: false)
        window.rootViewController = rootNavigationController
        
        window.makeKeyAndVisible()
        
        flowModel.selectCurrencyFlowModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectCurrencyFlowModel in
            
                self?.update(
                    selectCurrencyFlowModel: selectCurrencyFlowModel,
                    at: rootNavigationController
                )
            }.store(in: &observers)
    }
}
