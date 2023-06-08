//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import UIKit
import Combine

final class CurrencyConverterViewController: UIViewController {
    
    // MARK: - Types
    
    public typealias ViewModel = CurrencyConverterViewControllerViewModelImpl
    
    private typealias SectionId = Int
    
    private typealias ItemId = CurrencyCode
    
    // MARK: - Properties
    
    private static let mainSectionId = 0
    
    private var activityIndicatorView = UIActivityIndicatorView()
    
    private var textFieldGroup = UIView()
    
    private var textField = TextFieldWithInsets()
    
    private var tableView: UITableView!
    
    private var tableDataSource: UITableViewDiffableDataSource<SectionId, ItemId>!
    
    private var observers = Set<AnyCancellable>()
    
    public var viewModel: ViewModel? {
        
        didSet {
            bind(to: viewModel)
        }
    }
    
    // MARK: - Methods
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    private static func getApplicationDirectory() throws -> URL {
        
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        guard let url = urls.first else {
            throw NSError(domain: "Can't find application directory", code: 0)
        }
        
        return url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        layout()
        style()
        
        let httpClient = HTTPClientImpl(session: .shared)
        
        let latestRatesService = LatestRatesServiceImpl(
            baseURL: URL(string: "https://openexchangerates.org")!,
            appId: "e35c68874ce748278683128f76d62a74",
            httpClient: httpClient,
            dataMapper: LatestRatesEndpointDataMapperImpl()
        )
        
        let applicationDirectory = try! Self.getApplicationDirectory()
        
        let dateProvider = DateProviderImpl()
        
        let jsonDataCoder = DataCoderJSON()
        
        let cacheDirectoryName = "cached"
        
        let cacheDirectory = applicationDirectory.appendingPathComponent(cacheDirectoryName)
        
        let cacheBinaryLocalStorage = BinaryLocalStorageImpl(directory: cacheDirectory)
        
        let cacheLocalStorage = LocalStorageFiles(
            binaryLocalStorage: cacheBinaryLocalStorage,
            coder: jsonDataCoder
        )
        
        let latestRatesServiceCached = LatestRatesServiceCached(
            latestRatesService: latestRatesService,
            timeout: 100000,
            localStorage: cacheLocalStorage,
            dateProvider: dateProvider
        )
        
        let baseCurrency = "USD"
        
        let currencyConverterService = CurrencyConverterServiceImpl(
            baseCurrency: baseCurrency,
            latestRatesService: latestRatesServiceCached
        )
        
        let convertCurrencyUseCase = ConvertCurrencyUseCaseImpl(
            baseCurrency: baseCurrency,
            currencyConverterService: currencyConverterService
        )
        
        let currenciesService = CurrenciesServiceImpl(
            baseURL: URL(string: "https://openexchangerates.org")!,
            httpClient: HTTPClientImpl(session: .shared),
            dataMapper: CurrenciesEndpointDataMapperImpl()
        )
        
        let getCurrenciesUseCase = GetCurrenciesUseCaseImpl(currenciesService: currenciesService)
        
        let listSortedCurrenciesUseCase = ListSortedCurrenciesCaseImpl(getCurrenciesUseCase: getCurrenciesUseCase)
        
        
        viewModel = CurrencyConverterViewControllerViewModelImpl(
            baseCurrency: baseCurrency,
            didOpenCurrencySelector: { selectedCurrency in
            },
            didFailToLoad: {
                
            },
            convertCurrencyUseCase: convertCurrencyUseCase,
            listSortedCurrenciesUseCase: listSortedCurrenciesUseCase
        )
        
        Task(priority: .userInitiated) {
            await viewModel?.load()
        }
    }
    
    
    // MARK: - Methods
    
    private func update(isLoading: Bool) {
        
        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    private func update(itemsIds: [CurrencyCode]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionId, ItemId>()
        
        snapshot.appendSections([Self.mainSectionId])
        snapshot.appendItems(itemsIds)
        
        tableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func update(amount: String) {
        
        textField.text = amount
    }
    
    private func bind(to viewModel: ViewModel?) {
        
        guard let viewModel = viewModel else {
            observers.removeAll()
            return
        }
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                
                self?.update(isLoading: isLoading)
            }.store(in: &observers)
        
        viewModel.itemsIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] itemsIds in
                
                self?.update(itemsIds: itemsIds)
            }.store(in: &observers)
        
        viewModel.amount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] amount in
                
                self?.update(amount: amount)
            }.store(in: &observers)
    }
}

// MARK: - Setup Views

extension CurrencyConverterViewController: UITextFieldDelegate {
    
    func setupActivityIndicator() {
        
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    func setupTextField() {
        
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textFieldGroup.addSubview(textField)
        
        view.addSubview(textFieldGroup)
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString: String
    ) -> Bool {
        
        let allowedCharacters = CharacterSet(charactersIn:".0123456789")
        let characterSet = CharacterSet(charactersIn: replacementString)
        
        return allowedCharacters.isSuperset(of: characterSet) &&
            (
                replacementString.range(of: ".", options: .literal) == nil ||
                textField.text?.range(of: ".", options: .literal) == nil
            )
    }
    
    func setupTableView() {
        
        tableView = UITableView(frame: view.frame, style: .plain)
        
        self.tableView.register(
            CurrencyConverterViewControllerItemCell.self,
            forCellReuseIdentifier: CurrencyConverterViewControllerItemCell.reuseIdentifier
        )
        
        let dataSource = UITableViewDiffableDataSource<Int, CurrencyCode>(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, itemId in
                
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: CurrencyConverterViewControllerItemCell.reuseIdentifier,
                    for: indexPath
                ) as! CurrencyConverterViewControllerItemCell
                
                guard let self = self else {
                    return cell
                }
                
                let cellViewModel = self.viewModel?.getItem(for: itemId)
                
                guard let cellViewModel = cellViewModel else {
                    return cell
                }
                
                cell.fill(with: cellViewModel)
                return cell
            }
        )
        
        tableDataSource = dataSource
        tableView.dataSource = dataSource
        view.addSubview(tableView)
    }
    
    func setupViews() {
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.sizeToFit()
        
        navigationItem.title = "Currency converter"
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        
        view.addGestureRecognizer(tapGesture)
        
        setupActivityIndicator()
        setupTextField()
        setupTableView()
    }
}

// MARK: - Layout

extension CurrencyConverterViewController {
    
    private func layout() {
        
        Layout.apply(
            textFieldGroup: textFieldGroup,
            textField: textField
        )
        
        Layout.apply(
            view: view,
            textFieldGroup: textFieldGroup,
            tableView: tableView
        )
    }
}

// MARK: - Style

extension CurrencyConverterViewController {
    
    private func style() {
        
        Styles.apply(textField: textField)
        Styles.apply(textFieldGroup: textFieldGroup)
    }
}