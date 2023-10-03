//
//  MainFlowModelImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

import XCTest
import CurrencyConverter

final class MainFlowModelImplTests: XCTestCase {

    typealias SUT = (
        flowModel: MainFlowModel,
        factories: (
            currencyConverterViewModel: CurrencyConverterViewModelFactoryMock,
            selectCurrencyFlowModel: SelectCurrencyFlowModelFactoryMock
        )
    )

    func createSUT(baseCurrency: CurrencyCode) -> SUT {

        let currencyConverterViewModelFactory = CurrencyConverterViewModelFactoryMock()

        let selectCurrencyFlowModelFactory = SelectCurrencyFlowModelFactoryMock()

        let flowModel = MainFlowModelImpl(
            baseCurrency: baseCurrency,
            usedFactories: (
                selectCurrencyFlowModel: selectCurrencyFlowModelFactory,
                currencyConverterViewControllerViewModel: currencyConverterViewModelFactory
            )
        )

        return (
            flowModel,
            factories: (
                currencyConverterViewModelFactory,
                selectCurrencyFlowModelFactory
            )
        )
    }

    // MARK: - Methods

    func test_select() async throws {

        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)

        sut.factories.currencyConverterViewModel.willUseCurrencies = [
            .init(code: "USD", title: "", emoji: "")
        ]

        await sut.flowModel.currencyConverterViewControllerViewModel.load()

        // When
        sut.flowModel.currencyConverterViewControllerViewModel.changeSourceCurrency()

        // Then
        XCTAssertNotNil(sut.flowModel.selectCurrencyFlowModel.value)
    }

}

// MARK: - Helpers

class CurrencyConverterViewModelFactoryMock: CurrencyConverterViewModelFactory {

    // MARK: - Properties

    var willUseCurrencies: [Currency]!

    var willUseConvertionRates: [CurrencyCode: Double]?

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func make(
        baseCurrency: CurrencyCode,
        didOpenCurrencySelector: @escaping (CurrencyCode) -> Void,
        didFailToLoad: @escaping () -> Void
    ) -> ViewModel {

        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()

        listSortedCurrenciesUseCase.listWillReturn = { [weak self] _ in

            guard let self = self else {
                return .failure(.internalError)
            }

            return .success(willUseCurrencies)
        }

        let convertCurrencyUseCase = ConvertCurrencyUseCaseMock()

        convertCurrencyUseCase.convertWillReturn = { [weak self] _, _ in

            guard let self = self else {
                return .failure(.internalError)
            }

            guard let willUseConvertionRates = willUseConvertionRates else {
                return .failure(.internalError)
            }

            return .success(willUseConvertionRates)
        }

        return CurrencyConverterViewModelImpl(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: didOpenCurrencySelector,
            didFailToLoad: didFailToLoad,
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
    }
}

class SelectCurrencyFlowModelFactoryMock: SelectCurrencyFlowModelFactory {

    // MARK: - Properties

    let currencySelectionViewModelFactory = CurrencySelectionViewModelFactoryMock()

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func make(
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
