//
//  CurrencyConverterViewControllerItemCell+Styles.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

extension CurrencyConverterViewControllerItemCell {
    
    final class Styles {
        
        // MARK: - Properties
        
        private static let titleColor = UIColor.black
        private static let descriptionColor = UIColor.black
        private static let titleFont: UIFont = UIFont.preferredFont(forTextStyle: .headline)
        private static let descriptionFont: UIFont = UIFont.preferredFont(forTextStyle: .subheadline)
        
        private static let separatorColor = UIColor(named: "Color.Separator")!
        private static let backgroundColor = UIColor(named: "Color.Background")!
        private static let textColor = UIColor(named: "Color.Text")!
        
        // MARK: - Methods
        
        static func apply(contentView: UIView) {
            
            contentView.backgroundColor = backgroundColor
        }
        
        static func apply(flagLabel: UILabel) {

            flagLabel.sizeToFit()
            flagLabel.textAlignment = .center
            flagLabel.font = .preferredFont(forTextStyle: .largeTitle)
        }

        static func apply(titleLabel: UILabel) {
            
            titleLabel.numberOfLines = 1
            titleLabel.font = titleFont
            titleLabel.textColor = titleColor
            titleLabel.textAlignment = .left
            titleLabel.textColor = textColor
        }
        
        static func apply(amountLabel: UILabel) {
            
            amountLabel.numberOfLines = 1
            amountLabel.font = titleFont
            amountLabel.textColor = titleColor
            amountLabel.textAlignment = .right
            amountLabel.textColor = textColor
        }
        
        static func apply(descriptionLabel: UILabel) {
            
            descriptionLabel.numberOfLines = 1
            descriptionLabel.font = descriptionFont
            descriptionLabel.textColor = descriptionColor
            descriptionLabel.textAlignment = .left
            descriptionLabel.textColor = textColor
        }
        
        static func apply(bottomBorder: UIView) {
            
            bottomBorder.backgroundColor = separatorColor
        }
    }
}
