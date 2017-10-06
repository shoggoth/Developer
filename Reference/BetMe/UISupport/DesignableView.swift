//
//  DesignableView.swift
//  BetMe
//
//  Created by Rich Henry on 02/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.clear {

        didSet { layer.borderColor = borderColor.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {

        didSet { layer.borderWidth = borderWidth }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {

        didSet { layer.cornerRadius = cornerRadius }
    }
}
