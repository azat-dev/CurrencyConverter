//
//  CurrencySelectionItemCell+Styles.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 06.06.23.
//

import Foundation
import UIKit

extension CurrencySelectionItemCell {
    
    final class Styles {

        // MARK: - Properties
        
        private static let textColor = UIColor(named: "Color.Text")!
        private static let titleColor = textColor
        private static let descriptionColor = textColor
        
        private static let titleFont: UIFont = UIFont.preferredFont(forTextStyle: .headline)
        private static let descriptionFont: UIFont = UIFont.preferredFont(forTextStyle: .subheadline)
        
        private static let separatorColor = UIColor(named: "Color.Separator")!
        
        private static let backgroundColor = UIColor(named: "Color.Background")!
        
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
            titleLabel.textAlignment = .left
            titleLabel.textColor = titleColor
            
        }
        
        static func apply(descriptionLabel: UILabel) {
            
            descriptionLabel.numberOfLines = 1
            descriptionLabel.font = descriptionFont
            descriptionLabel.textColor = descriptionColor
            descriptionLabel.textAlignment = .left
        }
        
        static func apply(bottomBorder: UIView) {
            
            bottomBorder.backgroundColor = separatorColor
        }
    }
}
