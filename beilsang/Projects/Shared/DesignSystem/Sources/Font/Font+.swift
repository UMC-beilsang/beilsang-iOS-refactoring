//
//  Font+.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import UIKit

public enum fontFamily: String {
    case pretendard = "Pretendard"
    case nps = "NPS"
}

public extension UIFont {
    static func designFont(family: fontFamily, weight: UIFont.Weight, size: CGFloat) -> UIFont {
        let name: String
        
        switch family {
        case .pretendard:
            switch weight {
            case .bold: name = "Pretendard-Bold"
            case .semibold: name = "Pretendard-SemiBold"
            case .medium: name = "Pretendard-Medium"
            case .regular: name = "Pretendard-Regular"
            default: name = "Pretendard-Regular"
            }
            
        case .nps:
            switch weight {
            case .regular: name = "NPS-Regular"
            case .bold: name = "NPS-Bold"
            case .black: name = "NPS-ExtraBold"
            default: name = "NPS-Regular"
            }
        }
        
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
