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

    public typealias ViewModel = CurrencySelectionViewModel

    private typealias SectionId = Int

    private typealias ItemId = CurrencyCode

    // MARK: - Properties

    private static let mainSectionId = 0

    private var activityIndicatorView = UIActivityIndicatorView()

    private var searchBar = UISearchBar()

    private var tableView: UITableView!

    private var tableDataSource: UITableViewDiffableDataSource<SectionId, CurrencySelectionItemViewModel>!

    private var observers = Set<AnyCancellable>()

    private var viewModel: ViewModel

    // MARK: - Methods

    init(viewModel: ViewModel) {

        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setupViews()
        layout()
        style()
        bind(to: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Task(priority: .userInitiated) {
            await viewModel.load()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel.dispose()
    }

    // MARK: - Methods

    @MainActor
    private func update(isLoading: Bool) {

        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    @MainActor
    private func update(items: [CurrencySelectionItemViewModel], isFirstLoad: Bool) {

        var snapshot = NSDiffableDataSourceSnapshot<SectionId, CurrencySelectionItemViewModel>()

        snapshot.appendSections([Self.mainSectionId])
        snapshot.appendItems(items)

        tableDataSource.apply(snapshot, animatingDifferences: !isFirstLoad)
    }

    func bind(to viewModel: ViewModel?) {

        guard let viewModel = viewModel else {
            observers.removeAll()
            return
        }

        var isFirstLoad = true

        viewModel.isLoading
            .sink { [weak self] isLoading in

                self?.update(isLoading: isLoading)
            }.store(in: &observers)

        viewModel.items
            .removeDuplicates()
            .sink { [weak self] items in

                self?.update(
                    items: items,
                    isFirstLoad: isFirstLoad
                )

                isFirstLoad = false
            }.store(in: &observers)
    }
}

// MARK: - Setup Views

extension CurrencySelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        viewModel.toggleSelection(at: indexPath.row)
    }
}

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

        let dataSource = UITableViewDiffableDataSource<Int, CurrencySelectionItemViewModel>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, itemViewModel in

                let cell = tableView.dequeueReusableCell(
                    withIdentifier: CurrencySelectionItemCell.reuseIdentifier,
                    for: indexPath
                ) as? CurrencySelectionItemCell

                guard let cell = cell else {
                    fatalError("Can't dequeue a cell")
                }

                cell.fill(with: itemViewModel)
                return cell
            }
        )

        tableDataSource = dataSource
        tableView.dataSource = dataSource

        tableView.delegate = self
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
            activityIndicatorView: activityIndicatorView,
            searchBar: searchBar,
            tableView: tableView
        )
    }
}

// MARK: - Style

extension CurrencySelectionViewController {

    private func style() {

        Styles.apply(view: view)
        Styles.apply(tableView: tableView)
        Styles.apply(searchBar: searchBar)
    }
}

// MARK: - Methods

extension CurrencySelectionViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if let searchText = searchBar.text {

            Task(priority: .userInitiated) {
                await viewModel.filterItems(by: searchText)
            }
        }

        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""

        Task(priority: .userInitiated) {
            await viewModel.removeFilter()
        }

        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        Task(priority: .userInitiated) {
            await viewModel.filterItems(by: searchText)
        }
    }
}
