//
//  UIButton.swift
//  ClockTowerBell
//
//  Created by mona zheng on 5/15/21.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
