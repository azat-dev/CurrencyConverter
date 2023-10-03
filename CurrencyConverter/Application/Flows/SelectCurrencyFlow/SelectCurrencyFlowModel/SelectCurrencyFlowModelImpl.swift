//
//  SelectCurrencyFlowModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public final class SelectCurrencyFlowModelImpl: SelectCurrencyFlowModel {

    // MARK: - Properties

    public let currencySelectionViewControllerViewModel: CurrencySelectionViewModel

    private let initialCurrency: CurrencyCode

    private let didSelect: (CurrencyCode) -> Void

    private let didCancel: () -> Void

    // MARK: - Initializers

    public init(
        initialCurrency: CurrencyCode,
        didSelect: @escaping (CurrencyCode) -> Void,
        didCancel: @escaping () -> Void,
        didFailToLoad: @escaping () -> Void,
        didDispose: @escaping () -> Void,
        currencySelectionViewModelFactory: CurrencySelectionViewModelFactory
    ) {

        self.initialCurrency = initialCurrency
        self.didSelect = didSelect
        self.didCancel = didCancel

        currencySelectionViewControllerViewModel = currencySelectionViewModelFactory.make(
            initialSelectedCurrency: initialCurrency,
            onSelect: didSelect,
            onCancel: didCancel,
            onFailLoad: didFailToLoad,
            onDispose: didDispose
        )
    }

    // MARK: - Methods

    public func cancel() {
        didCancel()
    }
}
