//
//  ColorParser.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import UIKit

public extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
