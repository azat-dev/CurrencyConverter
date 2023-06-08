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
            tableView: UITableView
        ) {
            
            textFieldGroup.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                textFieldGroup.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                textFieldGroup.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                textFieldGroup.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                
                tableView.topAnchor.constraint(equalTo: textFieldGroup.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
        
        static func apply(
            textFieldGroup: UIView,
            textField: TextFieldWithInsets
        ) {
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            textField.insets = insets
            
            NSLayoutConstraint.activate([
                
                textField.topAnchor.constraint(equalTo: textFieldGroup.topAnchor),
                textField.bottomAnchor.constraint(equalTo: textFieldGroup.bottomAnchor),
                textField.leadingAnchor.constraint(equalTo: textFieldGroup.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: textFieldGroup.trailingAnchor)
            ])
        }
    }
}

