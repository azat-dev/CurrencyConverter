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
        
        static func apply(currentCurrencyFlag: UILabel) {
            
            currentCurrencyFlag.font = .preferredFont(forTextStyle: .title1)
            currentCurrencyFlag.textColor = textColor
            currentCurrencyFlag.numberOfLines = 1
            currentCurrencyFlag.adjustsFontSizeToFitWidth = true
        }
        
        static func apply(currentCurrencyLabel: UILabel) {
            
            currentCurrencyLabel.font = .preferredFont(forTextStyle: .headline)
            currentCurrencyLabel.textColor = textColor
        }
        
        static func apply(currentCurrencyArrow: UIImageView) {
            
            currentCurrencyArrow.image = UIImage(systemName: "chevron.down")?
                    .withTintColor(textColor)
            currentCurrencyArrow.contentMode = .scaleAspectFit
            currentCurrencyArrow.tintColor = textColor
        }
    }
}
