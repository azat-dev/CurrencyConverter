//
//  CurrencySelectionViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine
import XCTest

import CurrencyConverter

final class CurrencySelectionViewModelTests: XCTestCase {

    // swiftlint:disable large_tuple
    typealias SUT = (
        viewModel: CurrencySelectionViewModel,
        didSelectedCurrencies: ValueStore<[CurrencyCode]>,
        didCancelTimes: ValueStore<Int>,
        didFailLoadTimes: ValueStore<Int>,
        capturedIsLoadingSequence: ValueStore<[Bool]>,
        capturedItemsIdsSequence: ValueStore<[[CurrencyCode]]>,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCaseMock
    )
    // swiftlint:enable large_tuple

    private var observers = Set<AnyCancellable>()

    func createSUT(initialSelectedCurrency: CurrencyCode?) -> SUT {

        let listSortedCurrenciesUseCase = ListSortedCurrenciesUseCaseMock()

        let capturedIsLoadingSequence = ValueStore<[Bool]>([])
        let capturedItemsIdsSequence = ValueStore<[[CurrencyCode]]>([])

        let didSelectedCurrencies = ValueStore([CurrencyCode]())
        let didCancelTimes = ValueStore<Int>(0)
        let didFailLoadTimes = ValueStore<Int>(0)

        let viewModel = CurrencySelectionViewModelImpl(
            initialSelectedCurrency: initialSelectedCurrency,
            onSelect: { [weak didSelectedCurrencies] currency in

                guard let didSelectedCurrencies = didSelectedCurrencies else {
                    return
                }

                var newValues = didSelectedCurrencies.value
                newValues.append(currency)

                didSelectedCurrencies.value = newValues
            },
            onCancel: { [weak didCancelTimes] in

                guard let didCancelTimes = didCancelTimes else {
                    return
                }

                didCancelTimes.value += 1
            },
            onFailLoad: { [weak didFailLoadTimes] in

                guard let didFailLoadTimes = didFailLoadTimes else {
                    return
                }

                didFailLoadTimes.value += 1
            },
            onDispose: {},
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )

        viewModel.isLoading.sink { isLoading in

            var newValues = capturedIsLoadingSequence.value
            newValues.append(isLoading)

            capturedIsLoadingSequence.value = newValues

        }.store(in: &observers)

        viewModel.items.sink { items in

            var newValues = capturedItemsIdsSequence.value
            newValues.append(items.map { $0.id })

            capturedItemsIdsSequence.value = newValues

        }.store(in: &observers)

        return (
            viewModel,
            didSelectedCurrencies,
            didCancelTimes,
            didFailLoadTimes,
            capturedIsLoadingSequence,
            capturedItemsIdsSequence,
            listSortedCurrenciesUseCase
        )
    }

    // MARK: - Methods

    func test_load__fail() async throws {

        // Given
        let initialSelectedCurrency = "USD"
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .failure(.internalError)
        }

        // When
        await sut.viewModel.load()

        // Then
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true])
        XCTAssertEqual(sut.didFailLoadTimes.value, 1)
        XCTAssertEqual(sut.didSelectedCurrencies.value, [])
        XCTAssertEqual(sut.didCancelTimes.value, 0)
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, [[]])
    }

    func test_load__success() async throws {

        // Given

        let currencies = anyCurrencies()

        let initialSelectedCurrency = "USD"
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        // When
        await sut.viewModel.load()

        // Then
        XCTAssertEqual(sut.capturedIsLoadingSequence.value, [true, false])
        XCTAssertEqual(sut.didFailLoadTimes.value, 0)
        XCTAssertEqual(sut.didSelectedCurrencies.value, [])
        XCTAssertEqual(sut.didCancelTimes.value, 0)

        let expecteItemsIdsSequence = [
            [],
            currencies.map { $0.code }
        ]

        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expecteItemsIdsSequence)
    }

    func test_initial_active_item() async throws {

        // Given
        let currencies = anyCurrencies()

        let initialSelecteItemIndex = 1

        let initialSelectedCurrency = currencies[initialSelecteItemIndex].code
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }
        await sut.viewModel.load()

        // When
        // Init

        // Then
        verifyActiveFlags(
            in: sut.viewModel,
            currencies: currencies,
            expectedSelectedItemIndex: initialSelecteItemIndex
        )
    }

    func test_toggle_selection__has_initial_item() async throws {

        // Given
        let currencies = anyCurrencies()

        let initialSelecteItemIndex = 1
        let newSelectedItemIndex = 2

        let initialSelectedCurrency = currencies[initialSelecteItemIndex].code
        let sut = createSUT(initialSelectedCurrency: initialSelectedCurrency)

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in

            return .success(currencies)
        }
        await sut.viewModel.load()

        // When
        sut.viewModel.toggleSelection(at: newSelectedItemIndex)

        // Then
        verifyActiveFlags(
            in: sut.viewModel,
            currencies: currencies,
            expectedSelectedItemIndex: newSelectedItemIndex
        )
    }

    func test_toggle_selection__doesnt_have_initial_item() async throws {

        // Given
        let currencies = anyCurrencies()
        let newSelectedItemIndex = 2

        let sut = createSUT(initialSelectedCurrency: nil)
        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        await sut.viewModel.load()

        // When
        sut.viewModel.toggleSelection(at: newSelectedItemIndex)

        // Then

        verifyActiveFlags(
            in: sut.viewModel,
            currencies: currencies,
            expectedSelectedItemIndex: newSelectedItemIndex
        )
    }

    func test_filterItems__empty_text() async throws {

        // Given
        let currencies = anyCurrencies()

        let sut = createSUT(initialSelectedCurrency: nil)

        sut.listSortedCurrenciesUseCase.listWillReturn = { _ in
            return .success(currencies)
        }

        await sut.viewModel.load()

        // When
        await sut.viewModel.filterItems(by: "")

        // Then
        let allItems = currencies.map { $0.code }

        let expectedItemsSequence = [
            [],
            allItems,
            allItems
        ]

        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedItemsSequence)
    }

    func test_filterItems__not_empty_text() async throws {

        // Given
        let currencies = anyCurrencies()

        let filteredItem = currencies.first!
        let filteredItems = [filteredItem]

        let testSearchText = filteredItem.title.lowercased()

        let sut = createSUT(initialSelectedCurrency: nil)

        sut.listSortedCurrenciesUseCase.listWillReturn = { searchText in

            guard let searchText = searchText else {
                return .success(currencies)
            }

            XCTAssertEqual(searchText, testSearchText)
            return .success(filteredItems)
        }

        await sut.viewModel.load()

        // When
        await sut.viewModel.filterItems(by: testSearchText)

        // Then
        let allItems = currencies.map { $0.code }

        let expectedItemsSequence = [
            [],
            allItems,
            filteredItems.map { $0.code }
        ]

        XCTAssertEqual(sut.listSortedCurrenciesUseCase.capturedSearches, [nil, testSearchText])
        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedItemsSequence)
    }

    func test_removeFilter() async throws {

        // Given
        let currencies = anyCurrencies()

        let filteredItem = currencies.first!
        let filteredItems = [filteredItem]

        let sut = createSUT(initialSelectedCurrency: nil)

        sut.listSortedCurrenciesUseCase.listWillReturn = { searchText in

            guard searchText != nil else {
                return .success(currencies)
            }

            return .success(filteredItems)
        }

        await sut.viewModel.load()
        await sut.viewModel.filterItems(by: filteredItem.code.lowercased())

        // When
        await sut.viewModel.removeFilter()

        // Then
        let allItems = currencies.map { $0.code }

        let expectedItemsSequence = [
            [],
            allItems,
            [filteredItem.code],
            allItems
        ]

        XCTAssertEqual(sut.capturedItemsIdsSequence.value, expectedItemsSequence)
    }

    // MARK: - Helpers

    func verifyActiveFlags(
        in viewModel:
            CurrencySelectionViewModel,
        currencies: [Currency],
        expectedSelectedItemIndex: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectedIsActiveFlags = currencies.indices.map { $0 == expectedSelectedItemIndex}
        let receivedActiveFlags = viewModel.items.value.map { $0.isActive.value }

        XCTAssertEqual(receivedActiveFlags, expectedIsActiveFlags, file: file, line: line)
    }

    func anyCurrencies() -> [Currency] {

        return [
            .init(
                code: "USD",
                title: "Dollar",
                emoji: ""
            ),
            .init(
                code: "GBP",
                title: "Pounds",
                emoji: ""
            ),
            .init(
                code: "YEN",
                title: "Japan Yen",
                emoji: ""
            )
        ]
    }
}

// MARK: - Helpers

class ValueStore<T> {

    // MARK: - Properties

    var value: T

    // MARK: - Initializers

    init(_ value: T) {
        self.value = value
    }
}

class ListSortedCurrenciesUseCaseMock: ListSortedCurrenciesUseCase {

    // MARK: - Properties

    var listWillReturn: ((_ searchText: String?) -> Result<[Currency], ListSortedCurrenciesUseCaseError>)!

    var capturedSearches = [String?]()

    // MARK: - Initializers

    init() {}

    // MARK: - Methods

    func list(searchText: String?) async -> Result<[Currency], ListSortedCurrenciesUseCaseError> {

        capturedSearches.append(searchText)
        return listWillReturn(searchText)
    }
}
