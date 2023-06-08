//
//  CurrencyConverterViewController+Styles.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

extension CurrencyConverterViewController {
    
    final class Styles {
        
        // MARK: - Properties
        
        static let accentColor = UIColor(named: "Color.Accent")!
        static let backgroundColor = UIColor(named: "Color.Background")!
        static let textColor = UIColor(named: "Color.Text")!
        
        // MARK: - Methods
        
        static func apply(textField: TextFieldWithInsets) {
            
            textField.font = .preferredFont(forTextStyle: .title1)
            textField.textColor = textColor
        }
        
        static func apply(view: UIView) {
            
            view.backgroundColor = backgroundColor
        }
        
        static func apply(textFieldGroup: UIView) {
            
            textFieldGroup.layer.cornerRadius = 10.0
            textFieldGroup.layer.borderWidth = 2
            textFieldGroup.layer.borderColor = accentColor.cgColor
        }
    }
}
