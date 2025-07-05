//
//  ColorSystem.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import UIKit

public enum ColorSystem {
    // MARK: - Primary
    public static let primaryAlternative = AtomicColor.blue5
    public static let primaryNeutral = AtomicColor.blue10
    public static let primaryNormal = AtomicColor.blue40
    public static let primaryStrong = AtomicColor.blue45
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
    public static let decorateDimmerNormal = UIColor(hex: "#00000099")
    public static let decorateInteractionNormal = UIColor(hex: "#00000014")
    public static let decorateShadowNormal = UIColor(hex: "#00000029")
    public static let decorateScrimNormal = UIColor(hex: "#00000099")

    // MARK: - Line
    public static let lineAlternative = UIColor(hex: "#0000000A")
    public static let lineNormal = UIColor(hex: "#0000001F")
    public static let lineNeutral = UIColor(hex: "#00000014")
    public static let lineStrong = UIColor(hex: "#0000003D")

    // MARK: - Brand
    public static let brandKakaoContainer = UIColor(hex: "#FEE500")
    public static let brandKakaoSymbol = UIColor(hex: "#000000E6")
    public static let brandKakaoLabel = UIColor(hex: "#191919")

    // MARK: - Background
    public static let backgroundNormalNormal = AtomicColor.common0
    public static let backgroundNormalAlternative = AtomicColor.coolNeutral5
    public static let backgroundElevatedNormal = AtomicColor.common0
    public static let backgroundElevatedAlternative = AtomicColor.coolNeutral5
}
