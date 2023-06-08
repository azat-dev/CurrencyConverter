//
//  CurrencyConverterViewControllerItemCell+Layout.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

extension CurrencyConverterViewControllerItemCell {

    final class Layout {
        
        // MARK: - Properties
        
        static let padding = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
        static let seperatorHeight = 0.5
        static let playButtonSize = CGFloat(25)
        
        static let imageSize: CGFloat = 50
        
        // MARK: - Methods
        
        static func apply(
            contentView: UIView,
            flagLabel: UILabel,
            textGroup: UIStackView,
            titleLabel: UILabel,
            descriptionLabel: UILabel,
            bottomBorder: UIView
        ) {
            
            flagLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            textGroup.translatesAutoresizingMaskIntoConstraints = false
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                flagLabel.heightAnchor.constraint(equalToConstant: imageSize),
                flagLabel.widthAnchor.constraint(equalToConstant: imageSize),
                
                flagLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
                flagLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                flagLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
                flagLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),

                textGroup.centerYAnchor.constraint(equalTo: flagLabel.centerYAnchor),
                textGroup.leftAnchor.constraint(equalTo: flagLabel.rightAnchor, constant: 10),
                textGroup.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
                textGroup.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
                textGroup.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            ])
            
            NSLayoutConstraint.activate([
                
                bottomBorder.leftAnchor.constraint(equalTo: textGroup.leftAnchor),
                bottomBorder.rightAnchor.constraint(equalTo: textGroup.rightAnchor),
                
                bottomBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: seperatorHeight)
            ])
        }
    }
}
