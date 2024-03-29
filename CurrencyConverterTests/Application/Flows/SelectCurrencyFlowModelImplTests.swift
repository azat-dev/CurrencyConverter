//
//  SelectCurrencyFlowModelImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

import XCTest
import CurrencyConverter

final class SelectCurrencyFlowModelImplTests: XCTestCase {

    // swiftlint:disable large_tuple
    typealias SUT = (
        flowModel: SelectCurrencyFlowModel,
        currencySelectionViewModelFactory: CurrencySelectionViewModelFactoryMock,
        didCancelTimes: ValueStore<Int>,
        capturedDidSelectSequence: ValueStore<[CurrencyCode]>
    )
    // swiftlint:enable large_tuple

    func createSUT(initialCurrency: CurrencyCode) -> SUT {

        let currencySelectionViewModelFactory = CurrencySelectionViewModelFactoryMock()

        let didCancelTimes = ValueStore(0)

        let didCancelHandler = { [weak didCancelTimes] in

            guard let didCancelTimes = didCancelTimes else {
                return
            }

            didCancelTimes.value += 1
        }

        let didFailToLoadTimes = ValueStore(0)

        let didFailToLoadHandler = { [weak didFailToLoadTimes] in

            guard let didFailToLoadTimes = didFailToLoadTimes else {
                return
            }

            didFailToLoadTimes.value += 1
        }

        let capturedDidSelectSequence = ValueStore<[CurrencyCode]>([])

        let didSelectHandler = { [weak capturedDidSelectSequence] (currency: CurrencyCode) -> Void in

            guard let capturedDidSelectSequence = capturedDidSelectSequence else {
                return
            }

            var newCapturedDidSelectSequence = capturedDidSelectSequence.value
            newCapturedDidSelectSequence.append(currency)

            capturedDidSelectSequence.value = newCapturedDidSelectSequence
        }

        let didDisposeHandler = {
        }

        let flowModel = SelectCurrencyFlowModelImpl(
            initialCurrency: initialCurrency,
            didSelect: didSelectHandler,
            didCancel: didCancelHandler,
            didFailToLoad: didFailToLoadHandler,
            didDispose: didDisposeHandler,
            currencySelectionViewModelFactory: currencySelectionViewModelFactory
        )

        return (
            flowModel,
            currencySelectionViewModelFactory,
            didCancelTimes,
            capturedDidSelectSequence
        )
    }

    // MARK: - Methods

    func test_select() async throws {

        // Given
        let initialCurrency = "USD"
        let sut = createSUT(initialCurrency: initialCurrency)

        sut.currencySelectionViewModelFactory.willUseCurrencies = [
            .init(code: "USD", title: "", emoji: "")
        ]

        await sut.flowModel.currencySelectionViewControllerViewModel.load()

        // When
        sut.flowModel.currencySelectionViewControllerViewModel.toggleSelection(at: 0)

        // Then
        XCTAssertEqual(
            sut.capturedDidSelectSequence.value,
            [
                initialCurrency
            ]
        )
    }

    func test_cancel() async throws {

        // Given
        let initialCurrency = "USD"
        let sut = createSUT(initialCurrency: initialCurrency)

        sut.currencySelectionViewModelFactory.willUseCurrencies = [
            .init(code: "USD", title: "", emoji: "")
        ]

        await sut.flowModel.currencySelectionViewControllerViewModel.load()

        // When
        sut.flowModel.currencySelectionViewControllerViewModel.cancel()

        // Then
        XCTAssertEqual(
            sut.didCancelTimes.value,
            1
        )
    }

    func test_cancel_flow() async throws {

        // Given
        let initialCurrency = "USD"
        let sut = createSUT(initialCurrency: initialCurrency)

        sut.currencySelectionViewModelFactory.willUseCurrencies = [
            .init(code: "USD", title: "", emoji: "")
        ]

        await sut.flowModel.currencySelectionViewControllerViewModel.load()

        // When
        sut.flowModel.cancel()

        // Then
        XCTAssertEqual(
            sut.didCancelTimes.value,
            1
        )
    }

}

// MARK: - Helpers

class CurrencySelectionViewModelFactoryMock: CurrencySelectionViewModelFactory {

    // MARK: - Properties

    var willUseCurrencies: [Currency]!

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func make(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void,
        onDispose: @escaping () -> Void
    ) -> ViewModel {

        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()

        listSortedCurrenciesUseCase.listWillReturn = { [weak self] _ in

            guard let self = self else {
                return .failure(.internalError)
            }

            return .success(willUseCurrencies)
        }

        return CurrencySelectionViewModelImpl(
            initialSelectedCurrency: initialSelectedCurrency,
            onSelect: onSelect,
            onCancel: onCancel,
            onFailLoad: onFailLoad,
            onDispose: onDispose,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
    }
}
