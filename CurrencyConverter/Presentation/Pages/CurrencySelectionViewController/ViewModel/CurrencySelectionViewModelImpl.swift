//
//  CurrencySelectionViewModelImpl.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine

public final class CurrencySelectionViewModelImpl: CurrencySelectionViewModel {

    // MARK: - Properties

    public var isLoading = CurrentValueSubject<Bool, Never>(true)

    public var items = CurrentValueSubject<[CurrencySelectionItemViewModel], Never>([])

    private let listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase

    private var activeItemId: CurrencyCode?

    private let onSelect: (CurrencyCode) -> Void

    private let onCancel: () -> Void

    private let onFailLoad: () -> Void

    private let onDispose: () -> Void

    private var currentSearchText: String?

    // MARK: - Initializers

    public init(
        initialSelectedCurrency: CurrencyCode?,
        onSelect: @escaping (CurrencyCode) -> Void,
        onCancel: @escaping () -> Void,
        onFailLoad: @escaping () -> Void,
        onDispose: @escaping () -> Void,
        listSortedCurrenciesUseCase: ListSortedCurrenciesUseCase
    ) {

        self.activeItemId = initialSelectedCurrency
        self.onSelect = onSelect
        self.onCancel = onCancel
        self.onFailLoad = onFailLoad
        self.onDispose = onDispose
        self.listSortedCurrenciesUseCase = listSortedCurrenciesUseCase
    }
}

// MARK: - Input Methods

extension CurrencySelectionViewModelImpl {

    public func toggleSelection(at index: Int) {

        let currentItems = items.value

        assert(index < currentItems.count)

        if
            let activeItemId = activeItemId,
            let prevSelectedItem = currentItems.first(where: { $0.id == activeItemId }) {
            prevSelectedItem.deactivate()
        }

        let newActiveItem = currentItems[index]
        newActiveItem.activate()

        activeItemId = newActiveItem.id

        guard let activeItemId = activeItemId else {
            return
        }

        onSelect(activeItemId)
    }

    private func load(with searchText: String?, isSilent: Bool) async {

        if !isLoading.value && !isSilent {
            isLoading.value = true
        }

        let listResult = await listSortedCurrenciesUseCase.list(searchText: searchText)

        guard case .success(let currencies) = listResult else {

            onFailLoad()
            return
        }

        let newCurrencies = currencies.map { currency in

            return CurrencySelectionItemViewModel(
                id: currency.code,
                isActive: currency.code == activeItemId,
                title: currency.code,
                description: currency.title,
                emoji: currency.emoji
            )
        }

        await MainActor.run {
            items.value = newCurrencies
            isLoading.value = false
        }
    }

    public func load() async {

        await load(with: nil, isSilent: false)
    }

    public func filterItems(by text: String) async {

        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        await load(
            with: cleanedText.isEmpty ? nil : cleanedText,
            isSilent: true
        )
    }

    public func removeFilter() async {

        await load(with: nil, isSilent: false)
    }

    public func cancel() {

        onCancel()
    }

    public func dispose() {

        onDispose()
    }
}
