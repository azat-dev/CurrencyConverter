//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 03.06.23.
//

import UIKit
import Combine

final class CurrencySelectionViewController: UIViewController {
    
    // MARK: - Types
    
    public typealias ViewModel = CurrencySelectionViewControllerViewModel
    
    private typealias SectionId = Int
    
    private typealias ItemId = CurrencyCode
    
    // MARK: - Properties
    
    private static let mainSectionId = 0
    
    private var activityIndicatorView = UIActivityIndicatorView()
    
    private var searchBar = UISearchBar()
    
    private var tableView: UITableView!
    
    private var tableDataSource: UITableViewDiffableDataSource<SectionId, ItemId>!
    
    private var observers = Set<AnyCancellable>()
    
    public var viewModel: ViewModel? {
        
        didSet {
            bind(to: viewModel)
        }
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        layout()
        
        let currenciesService = CurrenciesServiceImpl(
            baseURL: URL(string: "https://openexchangerates.org")!,
            httpClient: HTTPClientImpl(session: .shared),
            dataMapper: CurrenciesEndpointDataMapperImpl()
        )
        
        let getCurrenciesUseCase = GetCurrenciesUseCaseImpl(currenciesService: currenciesService)
        
        let listSortedCurrenciesUseCase = ListSortedCurrenciesCaseImpl(getCurrenciesUseCase: getCurrenciesUseCase)
        
        viewModel = CurrencySelectionViewControllerViewModelImpl(
            initialSelectedCurrency: nil,
            onSelect: { newCurrency in
            },
            onCancel: {
                
            },
            onFailLoad: {
                
            },
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
    
    func bind(to viewModel: ViewModel?) {
        
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
    }
}

// MARK: - Setup Views

extension CurrencySelectionViewController {
    
    func setupActivityIndicator() {
        
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    func setupSearchBar() {
        
        searchBar.delegate = self
        searchBar.placeholder = "Search for a currency"
        view.addSubview(searchBar)
    }
    
    func setupTableView() {
        
        tableView = UITableView(frame: view.frame, style: .plain)
        
        self.tableView.register(
            CurrencySelectionItemCell.self,
            forCellReuseIdentifier: CurrencySelectionItemCell.reuseIdentifier
        )
        
        let dataSource = UITableViewDiffableDataSource<Int, CurrencyCode>(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, itemId in
                
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: CurrencySelectionItemCell.reuseIdentifier,
                    for: indexPath
                ) as! CurrencySelectionItemCell
                
                guard let self = self else {
                    return cell
                }
                
                let cellViewModel = self.viewModel?.getItem(at: indexPath.row)
                
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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        
        navigationItem.title = "Choose a currency"
        navigationItem.largeTitleDisplayMode = .always
        
        setupActivityIndicator()
        setupSearchBar()
        setupTableView()
    }
}

// MARK: - Layout

extension CurrencySelectionViewController {
    
    private func layout() {
        
        Layout.apply(
            view: view,
            searchBar: searchBar,
            tableView: tableView
        )
    }
}

// MARK: - Methods

extension CurrencySelectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            
            Task(priority: .userInitiated) {
                await viewModel?.filterItems(by: searchText)
            }
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        
        Task(priority: .userInitiated) {
            await viewModel?.removeFilter()
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        Task(priority: .userInitiated) {
            await viewModel?.filterItems(by: searchText)
        }
    }
}
