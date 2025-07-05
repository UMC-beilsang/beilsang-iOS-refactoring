//
//  Fonts.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import UIKit

public enum Fonts {
    case title1
    case heading1
    case heading2
    case heading3
    case body1
    case body2
    case detail1
    case detail2
    case subHeading1
    case subHeading2
    
    public var font: UIFont {
        switch self {
        case .title1:
            return .designFont(family: .pretendard, weight: .bold, size: 28)
        case .heading1:
            return .designFont(family: .pretendard, weight: .bold, size: 24)
        case .heading2:
            return .designFont(family: .pretendard, weight: .bold, size: 22)
        case .heading3:
            return .designFont(family: .pretendard, weight: .semibold, size: 18)
        case .body1:
            return .designFont(family: .pretendard, weight: .regular, size: 16)
        case .body2:
            return .designFont(family: .pretendard, weight: .regular, size: 14)
        case .detail1:
            return .designFont(family: .pretendard, weight: .regular, size: 12)
        case .detail2:
            return .designFont(family: .pretendard, weight: .regular, size: 11)
        case .subHeading1:
            return .designFont(family: .nps, weight: .black, size: 24)
        case .subHeading2:
            return .designFont(family: .nps, weight: .black, size: 18)
        }
    }
    
    public var letterSpacing: CGFloat {
        return -0.04
    }
    
    public var lineHeightMultiple: CGFloat {
        switch self {
        case .title1: return 1.0
        case .heading1, .heading2, .heading3: return 1.2
        case .body1, .body2, .detail1, .detail2, .subHeading1, .subHeading2:
            return 1.5
        }
    }
}

