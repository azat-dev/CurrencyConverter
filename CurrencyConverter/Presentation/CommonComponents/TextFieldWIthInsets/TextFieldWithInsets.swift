//
//  TextFieldWithInsets.swift
//  CurrencyConverter
//
//  Created by Azat Kaiumov on 08.06.23.
//

import Foundation
import UIKit

public final class TextFieldWithInsets: UITextField {

    // MARK: - Properties
    
    public var insets = UIEdgeInsets.zero {
        
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Methods

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}
