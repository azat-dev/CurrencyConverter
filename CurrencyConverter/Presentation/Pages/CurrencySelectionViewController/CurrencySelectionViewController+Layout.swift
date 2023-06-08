//
//  CurrencySelectionViewController+Layout.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import UIKit

extension CurrencySelectionViewController {
    
    final class Layout {
        
        static func apply(
            view: UIView,
            activityIndicatorView: UIActivityIndicatorView,
            searchBar: UISearchBar,
            tableView: UITableView
        ) {
            
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                
                tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
    }
}
