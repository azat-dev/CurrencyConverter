//
//  SelectCurrencyFlowModelImplFactory.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public final class SelectCurrencyFlowModelImplFactory: SelectCurrencyFlowModelFactory {

    // MARK: - Properties

    private let currencySelectionViewModelFactory: CurrencySelectionViewModelFactory

    // MARK: - Initializers

    public init(currencySelectionViewModelFactory: CurrencySelectionViewModelFactory) {

        self.currencySelectionViewModelFactory = currencySelectionViewModelFactory
    }

    // MARK: - Methods

    public func make(
        initialCurrency: CurrencyCode,
        didSelect: @escaping (CurrencyCode) -> Void,
        didCancel: @escaping () -> Void,
        didFailToLoad: @escaping () -> Void,
        didDispose: @escaping () -> Void
    ) -> FlowModel {

        return SelectCurrencyFlowModelImpl(
            initialCurrency: initialCurrency,
            didSelect: didSelect,
            didCancel: didCancel,
            didFailToLoad: didFailToLoad,
            didDispose: didDispose,
            currencySelectionViewModelFactory: currencySelectionViewModelFactory
        )
    }
}
