//
//  MainFlowModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public final class MainFlowModelImpl: MainFlowModel {

    public typealias UsedFactories = (
        selectCurrencyFlowModel: SelectCurrencyFlowModelFactory,
        currencyConverterViewControllerViewModel: CurrencyConverterViewModelFactory
    )

    // MARK: - Properties

    private let baseCurrency: CurrencyCode

    public let selectCurrencyFlowModel = CurrentValueSubject<SelectCurrencyFlowModel?, Never>(nil)

    private let factories: UsedFactories

    public lazy var currencyConverterViewControllerViewModel: CurrencyConverterViewModel = {

        return factories.currencyConverterViewControllerViewModel.make(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: { [weak self] (initialCurrency) in

                self?.runSelectCurrencyFlow(with: initialCurrency)
            },
            didFailToLoad: {
                print("IMPLEMENT ME")
            }
        )
    }()

    // MARK: - Initializers

    public init(
        baseCurrency: CurrencyCode,
        usedFactories: UsedFactories
    ) {

        self.baseCurrency = baseCurrency
        self.factories = usedFactories
    }

    // MARK: - Methods

    private func hideCurrencySelection() {

        selectCurrencyFlowModel.value = nil
    }

    func runSelectCurrencyFlow(with initialCurrency: CurrencyCode) {

        let handleSelectCurrency = { [weak self] (_ selectedCurrency: CurrencyCode) -> Void in

            guard let self = self else {
                return
            }

            Task(priority: .userInitiated) {

                self.hideCurrencySelection()
                await self.currencyConverterViewControllerViewModel.update(selectedCurrency: selectedCurrency)
            }
        }

        let handleCancel = { [weak self] () -> Void in

            self?.hideCurrencySelection()
        }

        let handleFailToLoad = { () -> Void in
            print("IMPLEMENT ME")
        }

        let handleDispose = { [weak self] () -> Void in

            self?.selectCurrencyFlowModel.value = nil
        }

        selectCurrencyFlowModel.value = factories.selectCurrencyFlowModel.make(
            initialCurrency: initialCurrency,
            didSelect: handleSelectCurrency,
            didCancel: handleCancel,
            didFailToLoad: handleFailToLoad,
            didDispose: handleDispose
        )
    }
}
