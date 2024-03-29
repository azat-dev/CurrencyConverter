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

    public typealias ViewModel = CurrencyConverterViewModel

    private typealias SectionId = Int

    private typealias ItemId = CurrencyCode

    // MARK: - Properties

    private static let mainSectionId = 0

    private var activityIndicatorView = UIActivityIndicatorView()

    private var currentCurrencyLabel = UILabel()

    private var currentCurrencyFlag = UILabel()

    private var currentCurrencyGroup = UIView()

    private var currentCurrencyArrow = UIImageView()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupViews()
        layout()
        style()

        Task(priority: .userInitiated) {
            await viewModel?.load()
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {

        let text = textField.text ?? ""

        Task(priority: .userInitiated) {

            await viewModel?.change(amount: text)
        }
    }

    @objc
    func didTapCurrencySelection() {

        viewModel?.changeSourceCurrency()
    }

    private func update(isLoading: Bool) {

        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    private func update(changedItems: [CurrencyCode]) {

        var snapshot = tableDataSource.snapshot()

        if #available(iOS 15.0, *) {

            snapshot.reconfigureItems(changedItems)
        } else {

            snapshot.reloadItems(changedItems)
        }

        tableDataSource.apply(snapshot, animatingDifferences: false)
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

    private func update(sourceCurrency: Currency?) {

        guard let sourceCurrency = sourceCurrency else {

            currentCurrencyGroup.isHidden = true
            return
        }

        currentCurrencyGroup.isHidden = false
        currentCurrencyLabel.text = sourceCurrency.code.uppercased()
        currentCurrencyFlag.text = sourceCurrency.emoji
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

        viewModel.changedItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changedItems in

                self?.update(changedItems: changedItems)
            }.store(in: &observers)

        viewModel.sourceCurrency
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sourceCurrency in

                self?.update(sourceCurrency: sourceCurrency)
            }.store(in: &observers)
    }
}

// MARK: - Setup Views

extension CurrencyConverterViewController: UITextFieldDelegate {

    func setupActivityIndicator() {

        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }

    func setupCurrentCurrencyGroup() {

        currentCurrencyGroup.isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(Self.didTapCurrencySelection)
        )

        currentCurrencyGroup.addGestureRecognizer(tapGestureRecognizer)

        currentCurrencyGroup.addSubview(currentCurrencyFlag)
        currentCurrencyGroup.addSubview(currentCurrencyLabel)
        currentCurrencyGroup.addSubview(currentCurrencyArrow)

        textFieldGroup.addSubview(currentCurrencyGroup)
    }

    func setupTextField() {

        textField.keyboardType = .decimalPad
        textField.delegate = self
        textFieldGroup.addSubview(textField)

        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )

        view.addSubview(textFieldGroup)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: replacementString)

        guard updatedText.count < 10 else {
            return false
        }

        let allowedCharacters = CharacterSet(charactersIn: ".0123456789")
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
                ) as? CurrencyConverterViewControllerItemCell

                guard let cell = cell else {
                    fatalError("Can't dequeue a cell")
                }

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
        setupCurrentCurrencyGroup()
    }
}

// MARK: - Layout

extension CurrencyConverterViewController {

    private func layout() {

        Layout.apply(
            currentCurrencyGroup: currentCurrencyGroup,
            currentCurrencyArrow: currentCurrencyArrow,
            currentCurrencyFlag: currentCurrencyFlag,
            currentCurrencyLabel: currentCurrencyLabel
        )

        Layout.apply(
            textFieldGroup: textFieldGroup,
            textField: textField,
            currentCurrencyGroup: currentCurrencyGroup
        )

        Layout.apply(
            view: view,
            textFieldGroup: textFieldGroup,
            activityIndicatorView: activityIndicatorView,
            tableView: tableView
        )
    }
}

// MARK: - Style

extension CurrencyConverterViewController {

    private func style() {

        Styles.apply(view: view)
        Styles.apply(textField: textField)
        Styles.apply(textFieldGroup: textFieldGroup)
        Styles.apply(tableView: tableView)

        Styles.apply(currentCurrencyArrow: currentCurrencyArrow)
        Styles.apply(currentCurrencyFlag: currentCurrencyFlag)
        Styles.apply(currentCurrencyLabel: currentCurrencyLabel)
    }
}
