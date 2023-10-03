//
//  CurrencySelectionViewController+Styles.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import UIKit

extension CurrencySelectionViewController {

    final class Styles {

        // MARK: - Properties

        static let backgroundColor = UIColor(named: "Color.Background")!

        // MARK: - Methods

        static func apply(view: UIView) {

            view.backgroundColor = backgroundColor
        }

        static func apply(tableView: UITableView) {

            tableView.backgroundColor = backgroundColor
        }

        static func apply(searchBar: UISearchBar) {

            searchBar.barTintColor = backgroundColor
        }
    }
}
