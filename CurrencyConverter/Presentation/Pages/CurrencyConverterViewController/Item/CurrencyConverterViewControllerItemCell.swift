//
//  CurrencyConverterViewControllerItemCell.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

public final class CurrencyConverterViewControllerItemCell: UITableViewCell {
    
    // MARK: - Types
    
    public typealias ViewModel = CurrencyConverterViewControllerItemViewModel
    
    // MARK: - Properties
    
    public static let reuseIdentifier = "CurrencyConverterViewControllerItemCell"

    private let textGroup = UIStackView()
    private let titleLabel = UILabel()
    private let descritionLabel = UILabel()
    private let flagLabel = UILabel()
    private let bottomBorder = UIView()
    
    // MARK: - Initializers
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Methods
    
    private func setup() {
        setupViews()
        layout()
        style()
    }
}

// MARK: - Fill from viewModel

extension CurrencyConverterViewControllerItemCell {

    func fill(with viewModel: ViewModel) {
        
        titleLabel.text = viewModel.title
        descritionLabel.text = viewModel.description
        flagLabel.text = viewModel.emoji
    }
}

// MARK: - Setup views

extension CurrencyConverterViewControllerItemCell {

    private func setupViews() {
        
        textGroup.axis = .vertical
        
        textGroup.addArrangedSubview(titleLabel)
        textGroup.addArrangedSubview(descritionLabel)
        
        contentView.addSubview(textGroup)
        contentView.addSubview(flagLabel)
        contentView.addSubview(bottomBorder)
    }
}

// MARK: - Style

extension CurrencyConverterViewControllerItemCell {

    private func style() {

        backgroundView = nil
        backgroundColor = .clear
        
        Styles.apply(contentView: contentView)
        Styles.apply(flagLabel: flagLabel)
        Styles.apply(titleLabel: titleLabel)
        Styles.apply(descriptionLabel: descritionLabel)
        Styles.apply(bottomBorder: bottomBorder)
    }
}

// MARK: - Layout

extension CurrencyConverterViewControllerItemCell {
    
    private func layout() {
        
        Layout.apply(
            contentView: contentView,
            flagLabel: flagLabel,
            textGroup: textGroup,
            titleLabel: titleLabel,
            descriptionLabel: descritionLabel,
            bottomBorder: bottomBorder
        )
    }
}
