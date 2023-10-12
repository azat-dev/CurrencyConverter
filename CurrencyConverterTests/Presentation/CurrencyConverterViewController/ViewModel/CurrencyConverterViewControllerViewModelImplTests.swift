//
//  CurrencyConverterViewModelImplTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine
import XCTest

import CurrencyConverter

final class CurrencyConverterViewModelImplTests: XCTestCase {

    // swiftlint:disable large_tuple
    typealias SUT = (
        viewModel: CurrencyConverterViewModel,

        convertCurrencyUseCase: ConvertCurrencyUseCaseMock,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCaseMock,

        didOpenCurrencySelector: ValueStore<[CurrencyCode]>,

        didFailToLoadTimes: ValueStore<Int>,

        capturedIsLoadingSequence: ValueStore<[Bool]>,
        capturedItemsIdsSequence: ValueStore<[[CurrencyCode]]>,
        capturedChangedItemsSequence: ValueStore<[[CurrencyCode]]>,
        capturedSourceCurrencySequence: ValueStore<[CurrencyCode?]>
    )
    // swiftlint:enable large_tuple

    private var observers = Set<AnyCancellable>()

    // swiftlint:disable function_body_length
    func createSUT(baseCurrency: CurrencyCode) -> SUT {

        let convertCurrencyUseCase = ConvertCurrencyUseCaseMock()
        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()

        let didOpenCurrencySelector = ValueStore<[CurrencyCode]>([])

        let handleOpenCurrencySelector = { [weak didOpenCurrencySelector] currency in

            guard let didOpenCurrencySelector = didOpenCurrencySelector else {
                return
            }

            var newValues = didOpenCurrencySelector.value
            newValues.append(currency)

            didOpenCurrencySelector.value = newValues
        }

        let didFailToLoadTimes = ValueStore<Int>(0)

        let handleFailToLoad = { [weak didFailToLoadTimes] in

            guard let didFailToLoadTimes = didFailToLoadTimes else {
                return
            }

            didFailToLoadTimes.value += 1
        }

        let viewModel = CurrencyConverterViewModelImpl(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: handleOpenCurrencySelector,
            didFailToLoad: handleFailToLoad,
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )

        let capturedIsLoadingSequence = ValueStore<[Bool]>([])

        viewModel.isLoading.sink { isLoading in

            var newValues = capturedIsLoadingSequence.value
            newValues.append(isLoading)

            capturedIsLoadingSequence.value = newValues

        }.store(in: &observers)

        let capturedItemsIdsSequence = ValueStore<[[CurrencyCode]]>([])

        viewModel.itemsIds.sink { itemsIds in

            var newValues = capturedItemsIdsSequence.value
            newValues.append(itemsIds)

            capturedItemsIdsSequence.value = newValues

        }.store(in: &observers)

        let capturedChangedItemsSequence = ValueStore<[[CurrencyCode]]>([])

        viewModel.changedItems.sink { changedItems in

            var newValues = capturedChangedItemsSequence.value
            newValues.append(changedItems)

            capturedChangedItemsSequence.value = newValues

        }.store(in: &observers)

        let capturedSourceCurrencySequence = ValueStore<[CurrencyCode?]>([])

        viewModel.sourceCurrency.sink { currency in

            var newValues = capturedSourceCurrencySequence.value
            newValues.append(currency?.code)

            capturedSourceCurrencySequence.value = newValues

        }.store(in: &observers)

        return (
            viewModel,

            convertCurrencyUseCase,
            listSortedCurrenciesUseCase,

            didOpenCurrencySelector,
            didFailToLoadTimes,

            capturedIsLoadingSequence,
            capturedItemsIdsSequence,
            capturedChangedItemsSequence,
            capturedSourceCurrencySequence
        )
    }
    // swiftlint:enable function_body_length

    // MARK: - Methods

    func test_load__fail() async throws {

        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .failure(.internalError)
        }

        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in
            return .failure(.internalError)
        }

        // When
        await sut.viewModel.load()

        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 1)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true])
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, [[]])
        XCTAssertEqual(sut.capturedChangedItemsSequence.value, [])
        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil])
    }

    func test_load__success() async throws {

        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)

        let currencies: [Currency] = [

            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: "")
        ]

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in

            return .success([
                "EUR": 1.111,
                "GBP": 2.222
            ])
        }

        // When
        await sut.viewModel.load()

        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil, baseCurrency])

        let expectedIdsSequence = [
            [],
            ["EUR", "GBP"]
        ]
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedIdsSequence)
        XCTAssertEqual(sut.capturedChangedItemsSequence.value, [])

        verifyAmounts(sut: sut, expectedAmounts: ["1.11", "2.22"])
    }

    func test_changeSourceCurrency() async throws {

        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)

        let currencies: [Currency] = [

            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: "")
        ]

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in

            return .success([
                "EUR": 1.11,
                "GBP": 2.22
            ])
        }

        await sut.viewModel.load()

        // When
        sut.viewModel.changeSourceCurrency()

        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [baseCurrency])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil, baseCurrency])

        XCTAssertEqual(sut.capturedItemsIdsSequence.value, [[], ["EUR", "GBP"]])
        XCTAssertEqual(sut.capturedChangedItemsSequence.value, [])
        verifyAmounts(sut: sut, expectedAmounts: ["1.11", "2.22"])
    }

    func test_updateSelectedCurrency() async throws {

        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)

        let newSelectedCurrency = "EUR"

        let currencies: [Currency] = [

            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: "")
        ]

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        sut.convertCurrencyUseCase.convertWillReturn = { _, sourceCurrency in

            if sourceCurrency == newSelectedCurrency {
                return .success([
                    "USD": 3.333,
                    "GBP": 4.444
                ])
            }

            return .success([
                "EUR": 1.111,
                "GBP": 2.222
            ])
        }

        await sut.viewModel.load()

        // When
        await sut.viewModel.update(selectedCurrency: newSelectedCurrency)

        // Then
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false, false])

        XCTAssertEqual(
            sut.capturedSourceCurrencySequence.value,
            [nil, baseCurrency, newSelectedCurrency]
        )

        let expectedIdsSequence = [
            [],
            ["EUR", "GBP"],
            ["USD", "GBP"]
        ]
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedIdsSequence)

        let expectedChangedItemsSequence = [
            ["USD", "GBP"]
        ]

        XCTAssertEqual(sut.capturedChangedItemsSequence.value, expectedChangedItemsSequence)

        verifyAmounts(sut: sut, expectedAmounts: ["3.33", "4.44"])
    }

    func test_changeAmount() async throws {

        // Given
        let baseCurrency = "USD"
        let sut = createSUT(baseCurrency: baseCurrency)

        let newAmount = 3.333333

        let currencies: [Currency] = [

            .init(code: "USD", title: "", emoji: ""),
            .init(code: "EUR", title: "", emoji: ""),
            .init(code: "GBP", title: "", emoji: "")
        ]

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        sut.convertCurrencyUseCase.convertWillReturn = { _, _ in

            return .success([
                "EUR": 1.111,
                "GBP": 2.222
            ])
        }

        await sut.viewModel.load()

        // When
        await sut.viewModel.change(amount: "\(newAmount)")

        // Then
        XCTAssertEqual(sut.viewModel.amount.value, "\(newAmount)")
        XCTAssertEqual(sut.didFailToLoadTimes.value, 0)
        XCTAssertEqual(sut.didOpenCurrencySelector.value, [])

        XCTAssertEqual(sut.capturedSourceCurrencySequence.value, [nil, baseCurrency])

        let expectedIdsSequence = [
            [],
            ["EUR", "GBP"]
        ]
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedIdsSequence)

        verifyAmounts(sut: sut, expectedAmounts: ["1.11", "2.22"])

        let expectedChangedItemsSequence = [
            ["EUR", "GBP"]
        ]

        XCTAssertEqual(sut.capturedChangedItemsSequence.value, expectedChangedItemsSequence)
    }

    // MARK: - Helpers

    func verifyAmounts(
        sut: SUT,
        expectedAmounts: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let capturedAmounts = sut.viewModel.itemsIds.value.compactMap { id in

            let item = sut.viewModel.getItem(for: id)
            return item?.amount
        }

        XCTAssertEqual(
            capturedAmounts,
            expectedAmounts,
            file: file,
            line: line
        )
    }
}
