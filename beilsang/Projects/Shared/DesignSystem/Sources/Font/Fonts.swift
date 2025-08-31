//
//  Fonts.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import SwiftUI

/// 앱 전체에서 사용하는 폰트 정의
public enum Fonts {
    // MARK: - Title
    case title1Bold
    
    // MARK: - Heading
    case heading1Bold, heading1SemiBold
    case heading2Bold, heading2SemiBold
    case heading3Bold, heading3SemiBold, heading3Medium
    
    // MARK: - Body
    case body1Bold, body1SemiBold, body1Medium
    case body2SemiBold, body2Medium, body2Regular
    
    // MARK: - Detail
    case detail1Medium, detail1Regular
    case detail2Regular
    
    // MARK: - Sub Heading (NPS Font)
    case subHeading1Bold
    case subHeading2ExtraBold
}

extension Fonts {
    /// SwiftUI Font 매핑
    public var font: Font {
        switch self {
            
        // Title
        case .title1Bold:
            return .custom("Pretendard-Bold", size: 28)
            
        // Heading 1
        case .heading1Bold:
            return .custom("Pretendard-Bold", size: 24)
        case .heading1SemiBold:
            return .custom("Pretendard-SemiBold", size: 24)
            
        // Heading 2
        case .heading2Bold:
            return .custom("Pretendard-Bold", size: 22)
        case .heading2SemiBold:
            return .custom("Pretendard-SemiBold", size: 22)
            
        // Heading 3
        case .heading3Bold:
            return .custom("Pretendard-Bold", size: 18)
        case .heading3SemiBold:
            return .custom("Pretendard-SemiBold", size: 18)
        case .heading3Medium:
            return .custom("Pretendard-Medium", size: 18)
            
        // Body 1
        case .body1Bold:
            return .custom("Pretendard-Bold", size: 16)
        case .body1SemiBold:
            return .custom("Pretendard-SemiBold", size: 16)
        case .body1Medium:
            return .custom("Pretendard-Medium", size: 16)
            
        // Body 2
        case .body2SemiBold:
            return .custom("Pretendard-SemiBold", size: 14)
        case .body2Medium:
            return .custom("Pretendard-Medium", size: 14)
        case .body2Regular:
            return .custom("Pretendard-Regular", size: 14)
            
        // Detail 1
        case .detail1Medium:
            return .custom("Pretendard-Medium", size: 12)
        case .detail1Regular:
            return .custom("Pretendard-Regular", size: 12)
            
        // Detail 2
        case .detail2Regular:
            return .custom("Pretendard-Regular", size: 11)
            
        // Sub Heading (NPS 전용)
        case .subHeading1Bold:
            return .custom("NPS-font-Bold", size: 24)
        case .subHeading2ExtraBold:
            return .custom("NPS-font-ExtraBold", size: 18)
        }
    }
    
    /// 공통 letterSpacing (토큰에서 -4%)
    public var letterSpacing: CGFloat { -0.04 }
    
    /// lineHeightMultiple (JSON 기준)
    public var lineHeightMultiple: CGFloat {
        switch self {
        case .title1Bold:
            return 1.0
        case .heading1Bold, .heading1SemiBold,
             .heading2Bold, .heading2SemiBold,
             .heading3Bold, .heading3SemiBold, .heading3Medium:
            return 1.2
        default:
            return 1.5
        }
    }
}
