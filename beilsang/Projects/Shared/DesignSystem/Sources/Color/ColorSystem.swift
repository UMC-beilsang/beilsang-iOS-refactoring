//
//  ColorSystem.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import SwiftUI

public enum ColorSystem {
    // MARK: - Primary
    public static let primaryAlternative = AtomicColor.blue5
    public static let primaryNeutral = AtomicColor.blue10
    public static let primaryNormal = AtomicColor.blue40
    public static let primaryStrong = AtomicColor.blue50
    public static let primaryHeavy = AtomicColor.blue55

    // MARK: - Label
    public static let labelWhite = AtomicColor.common0
    public static let labelBlack = AtomicColor.common100

    public static let labelNormalDisable = AtomicColor.coolNeutral5
    public static let labelNormalAssistive = AtomicColor.coolNeutral10
    public static let labelNormalAlternative = AtomicColor.coolNeutral20
    public static let labelNormalNeutral = AtomicColor.coolNeutral30
    public static let labelNormalBasic = AtomicColor.coolNeutral50
    public static let labelNormalNormal = AtomicColor.coolNeutral85
    public static let labelNormalStrong = AtomicColor.coolNeutral93

    // MARK: - Semantic
    public static let semanticNegativeNormal = AtomicColor.red5
    public static let semanticNegativeStrong = AtomicColor.red20
    public static let semanticNegativeHeavy = AtomicColor.red55

    public static let semanticPositiveNormal = AtomicColor.blue5
    public static let semanticPositiveStrong = AtomicColor.blue10
    public static let semanticPositiveHeavy = AtomicColor.blue55

    public static let semanticCautionaryNormal = AtomicColor.orange10
    public static let semanticCautionaryStrong = AtomicColor.orange20
    public static let semanticCautionaryHeavy = AtomicColor.orange55

    // MARK: - Decorate (직접 hex 코드 사용)
    public static let decorateDimmerNormal = Color(hex: "#000000", alpha: 0.6)   // 99 = 약 60%
    public static let decorateInteractionNormal = Color(hex: "#000000", alpha: 0.08) // 14 = 약 8%
    public static let decorateShadowNormal = Color(hex: "#000000", alpha: 0.16) // 29 = 약 16%
    public static let decorateScrimNormal = Color(hex: "#000000", alpha: 0.6)   // 99 = 약 60%

    // MARK: - Line
    public static let lineAlternative = Color(hex: "#000000", alpha: 0.04) // 0A = 약 4%
    public static let lineNormal = Color(hex: "#000000", alpha: 0.12)      // 1F = 약 12%
    public static let lineNeutral = Color(hex: "#000000", alpha: 0.08)     // 14 = 약 8%
    public static let lineStrong = Color(hex: "#000000", alpha: 0.24)      // 3D = 약 24%

    // MARK: - Brand
    public static let brandKakaoContainer = Color(hex: "#FEE500")
    public static let brandKakaoSymbol = Color(hex: "#000000", alpha: 0.9) // E6 = 약 90%
    public static let brandKakaoLabel = Color(hex: "#191919")

    // MARK: - Background
    public static let backgroundNormalNormal = AtomicColor.common0
    public static let backgroundNormalAlternative = AtomicColor.neutral5
    public static let backgroundElevatedNormal = AtomicColor.common0
    public static let backgroundElevatedAlternative = AtomicColor.coolNeutral5
}

