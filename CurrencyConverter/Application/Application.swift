//
//  Application.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

public final class Application {
    
    // MARK: - Properties
    
    private let presenter: MainFlowPresenter
    
    // MARK: - Initializers
    
    public init(settings: ApplicationSettings) {
        
        let flowModel = Self.makeFlowModel(settings: settings)
        presenter = Self.makePresenter(for: flowModel)
    }
    
    // MARK: - Methods
    
    static func makeFlowModel(settings: ApplicationSettings) -> MainFlowModel {
        
        let httpClient = HTTPClientImpl(session: .shared)
        
        let dateProvider = DateProviderImpl()
        
        let jsonDataCoder = DataCoderJSON()
        
        let applicationDirectory = try! Self.getApplicationDirectory()
        
        let cacheDirectory = applicationDirectory.appendingPathComponent(settings.cacheDirectoryName)
        
        let cacheBinaryLocalStorage = BinaryLocalStorageImpl(directory: cacheDirectory)
        
        let cacheLocalStorage = LocalStorageFiles(
            binaryLocalStorage: cacheBinaryLocalStorage,
            coder: jsonDataCoder
        )
        
        let currenciesService = CurrenciesServiceImpl(
            baseURL: settings.baseURL,
            httpClient: httpClient,
            dataMapper: CurrenciesEndpointDataMapperImpl()
        )
        
        let currenciesServiceCached = CurrenciesServiceCached(
            currenciesService: currenciesService,
            timeout: settings.cacheRefreshTimeout,
            localStorage: cacheLocalStorage,
            dateProvider: dateProvider
        )
        
        let getCurrenciesUseCase = GetCurrenciesUseCaseImpl(currenciesService: currenciesServiceCached)
        
        let listSortedCurrenciesUseCase = ListSortedCurrenciesCaseImpl(getCurrenciesUseCase: getCurrenciesUseCase)
        
        let currencySelectionViewControllerViewModelFactory = CurrencySelectionViewControllerViewModelImplFactory(
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
        
        let selectCurrencyFlowModelFactory = SelectCurrencyFlowModelImplFactory(
            currencySelectionViewControllerViewModelFactory: currencySelectionViewControllerViewModelFactory
        )
        
        let latestRatesService = LatestRatesServiceImpl(
            baseURL: settings.baseURL,
            appId: settings.appId,
            httpClient: httpClient,
            dataMapper: LatestRatesEndpointDataMapperImpl()
        )
        
        let latestRatesServiceCached = LatestRatesServiceCached(
            latestRatesService: latestRatesService,
            timeout: settings.cacheRefreshTimeout,
            localStorage: cacheLocalStorage,
            dateProvider: dateProvider
        )
        
        let currencyConverterService = CurrencyConverterServiceImpl(
            baseCurrency: settings.baseCurrency,
            latestRatesService: latestRatesServiceCached
        )
        
        let convertCurrencyUseCase = ConvertCurrencyUseCaseImpl(
            baseCurrency: settings.baseCurrency,
            currencyConverterService: currencyConverterService
        )
        
        let currencyConverterViewControllerViewModelFactory = CurrencyConverterViewControllerViewModelImplFactory(
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
        
        return MainFlowModelImpl(
            baseCurrency: settings.baseCurrency,
            usedFactories: (
                selectCurrencyFlowModel: selectCurrencyFlowModelFactory,
                currencyConverterViewControllerViewModel: currencyConverterViewControllerViewModelFactory
            )
        )
    }
    
    private static func makePresenter(for flowModel: MainFlowModel) -> MainFlowPresenter {
        
        let selectCurrencyFlowPresenterFactory = SelectCurrencyFlowPresenterImplFactory()
        
        return MainFlowPresenterImpl(
            flowModel: flowModel,
            selectCurrencyFlowPresenterFactory: selectCurrencyFlowPresenterFactory
        )
    }
    
    public func present(at window: UIWindow) {
        
        presenter.present(at: window)
    }
    
    // MARK: - Helpers
    
    private static func getApplicationDirectory() throws -> URL {
        
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        guard let url = urls.first else {
            throw NSError(domain: "Can't find application directory", code: 0)
        }
        
        return url
    }
}
