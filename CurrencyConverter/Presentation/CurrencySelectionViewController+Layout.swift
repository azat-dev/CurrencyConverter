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
            tableView: UITableView
        ) {
            
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
    }
}
