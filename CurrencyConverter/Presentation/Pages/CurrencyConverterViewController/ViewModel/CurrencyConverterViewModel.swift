//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import Combine

public protocol CurrencyConverterViewModelOutput {

    // MARK: - Properties

    var isLoading: CurrentValueSubject<Bool, Never> { get }

    var amount: CurrentValueSubject<String, Never> { get }

    var sourceCurrency: CurrentValueSubject<Currency?, Never> { get }

    var itemsIds: CurrentValueSubject<[CurrencyCode], Never> { get }

    var changedItems: PassthroughSubject<[CurrencyCode], Never> { get }

    // MARK: - Methods

    func getItem(for id: CurrencyCode) -> CurrencyConverterItemViewModel?
}

public protocol CurrencyConverterViewModelInput {

    func change(amount: String) async

    func changeSourceCurrency()

    func load() async
}

public protocol CurrencyConverterViewModelUpdateProperties {

    func update(selectedCurrency: CurrencyCode) async
}

public protocol CurrencyConverterViewModel:
    CurrencyConverterViewModelOutput,
    CurrencyConverterViewModelInput,
    CurrencyConverterViewModelUpdateProperties {}
