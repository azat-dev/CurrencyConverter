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
        
        
        // MARK: - Methods
        
        static func apply(textField: TextFieldWithInsets) {
            
            textField.font = .preferredFont(forTextStyle: .title1)
        }
        
        static func apply(textFieldGroup: UIView) {
            
            textFieldGroup.layer.cornerRadius = 10.0
            textFieldGroup.layer.borderWidth = 2
            textFieldGroup.layer.borderColor = UIColor.red.cgColor
        }
    }
}
