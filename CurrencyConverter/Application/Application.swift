//
//  Application.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation

public struct ApplicationSettings {
    
    // MARK: - Properties
    
    public let baseURL: URL
    public let appId: String
    public let cacheDirectoryName: String
    public let cacheRefreshTimeout: TimeInterval
    public let baseCurrency: String
    
    // MARK: - Initializers

    public init(
        baseURL: URL,
        appId: String,
        cacheDirectoryName: String,
        cacheRefreshTimeout: TimeInterval,
        baseCurrency: String
    ) {
        self.baseURL = baseURL
        self.appId = appId
        self.cacheDirectoryName = cacheDirectoryName
        self.cacheRefreshTimeout = cacheRefreshTimeout
        self.baseCurrency = baseCurrency
    }
}

public final class Application {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
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
    
    private static func getApplicationDirectory() throws -> URL {
        
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        guard let url = urls.first else {
            throw NSError(domain: "Can't find application directory", code: 0)
        }
        
        return url
    }
}
