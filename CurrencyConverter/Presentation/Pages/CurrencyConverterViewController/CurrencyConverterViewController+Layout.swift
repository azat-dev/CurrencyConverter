//
//  CurrencyConverterViewController+Layout.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

extension CurrencyConverterViewController {

    final class Layout {

        static func apply(
            view: UIView,
            textFieldGroup: UIView,
            activityIndicatorView: UIActivityIndicatorView,
            tableView: UITableView
        ) {

            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            textFieldGroup.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([

                activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                textFieldGroup.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                textFieldGroup.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                textFieldGroup.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -10
                ),

                tableView.topAnchor.constraint(equalTo: textFieldGroup.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        static func apply(
            currentCurrencyGroup: UIView,
            currentCurrencyArrow: UIImageView,
            currentCurrencyFlag: UILabel,
            currentCurrencyLabel: UILabel
        ) {

            currentCurrencyArrow.translatesAutoresizingMaskIntoConstraints = false
            currentCurrencyFlag.translatesAutoresizingMaskIntoConstraints = false
            currentCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false

            currentCurrencyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            currentCurrencyLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
            currentCurrencyArrow.setContentCompressionResistancePriority(.init(1000), for: .horizontal)

            NSLayoutConstraint.activate([

                currentCurrencyFlag.centerYAnchor.constraint(equalTo: currentCurrencyGroup.centerYAnchor),
                currentCurrencyLabel.centerYAnchor.constraint(equalTo: currentCurrencyGroup.centerYAnchor),
                currentCurrencyArrow.centerYAnchor.constraint(equalTo: currentCurrencyGroup.centerYAnchor),

                currentCurrencyFlag.leadingAnchor.constraint(equalTo: currentCurrencyGroup.leadingAnchor),
                currentCurrencyFlag.trailingAnchor.constraint(
                    equalTo: currentCurrencyLabel.leadingAnchor,
                    constant: -5
                ),

                currentCurrencyLabel.trailingAnchor.constraint(
                    equalTo: currentCurrencyArrow.leadingAnchor,
                    constant: -5
                ),

                currentCurrencyArrow.trailingAnchor.constraint(
                    equalTo: currentCurrencyGroup.trailingAnchor,
                    constant: -10
                )
            ])
        }

        static func apply(
            textFieldGroup: UIView,
            textField: TextFieldWithInsets,
            currentCurrencyGroup: UIView
        ) {

            textField.translatesAutoresizingMaskIntoConstraints = false
            currentCurrencyGroup.translatesAutoresizingMaskIntoConstraints = false

            let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 0)
            textField.insets = insets

            NSLayoutConstraint.activate([

                textField.topAnchor.constraint(equalTo: textFieldGroup.topAnchor),
                textField.bottomAnchor.constraint(equalTo: textFieldGroup.bottomAnchor),

                textField.leadingAnchor.constraint(equalTo: textFieldGroup.leadingAnchor),

                currentCurrencyGroup.leadingAnchor.constraint(equalTo: textField.trailingAnchor),
                currentCurrencyGroup.trailingAnchor.constraint(equalTo: textFieldGroup.trailingAnchor),

                currentCurrencyGroup.topAnchor.constraint(equalTo: textField.topAnchor),
                currentCurrencyGroup.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
            ])

            textField.setContentHuggingPriority(.init(100), for: .horizontal)
            textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            currentCurrencyGroup.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            currentCurrencyGroup.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        }
    }
}
