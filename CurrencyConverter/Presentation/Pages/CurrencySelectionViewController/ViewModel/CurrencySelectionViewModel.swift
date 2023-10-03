//
//  CurrencySelectionViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import Combine

public protocol CurrencySelectionViewModelOutput {

    // MARK: - Properties

    var isLoading: CurrentValueSubject<Bool, Never> { get }

    var items: CurrentValueSubject<[CurrencySelectionItemViewModel], Never> { get }
}

public protocol CurrencySelectionViewModelInput {

    func load() async

    func toggleSelection(at index: Int)

    func filterItems(by text: String) async

    func removeFilter() async

    func cancel()

    func dispose()
}

public protocol CurrencySelectionViewModel:
    CurrencySelectionViewModelOutput,
    CurrencySelectionViewModelInput {}
