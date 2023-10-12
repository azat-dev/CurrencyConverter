//
//  ListSortedCurrenciesUseCaseMock.swift
//  CurrencyConverterTests
//
//  Created by Azat Kaiumov on 12.10.23.
//

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
