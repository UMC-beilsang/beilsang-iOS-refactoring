//
//  NicknameStyle.swift
//  DesignSystemShared
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI
import ModelsShared

public struct NicknameStyle {
    public let background: Color
    public let border: Color
    public let text: Color
    public let buttonBackground: Color
    public let buttonText: Color
    public let alretText: Color
    public let isButtonEnabled: Bool
}

public extension NicknameState {
    var style: NicknameStyle {
        switch self {
        case .idle:
            return NicknameStyle(
                background: ColorSystem.labelNormalDisable,
                border: .clear,
                text: ColorSystem.labelNormalStrong,
                buttonBackground: ColorSystem.labelNormalAlternative,
                buttonText: ColorSystem.labelNormalBasic,
                alretText: ColorSystem.labelNormalBasic,
                isButtonEnabled: false
            )
        case .focused:
            return NicknameStyle(
                background: ColorSystem.labelNormalDisable,
                border: .clear,
                text: ColorSystem.labelNormalStrong,
                buttonBackground: ColorSystem.labelNormalAlternative,
                buttonText: ColorSystem.labelNormalBasic,
                alretText: ColorSystem.labelNormalBasic,
                isButtonEnabled: false
            )
        case .typing:
            return NicknameStyle(
                background: ColorSystem.labelNormalDisable,
                border: .clear,
                text: ColorSystem.labelNormalStrong,
                buttonBackground: ColorSystem.primaryStrong,
                buttonText: ColorSystem.labelWhite,
                alretText: ColorSystem.labelNormalBasic,
                isButtonEnabled: true
            )
        case .filled:
            return NicknameStyle(
                background: ColorSystem.labelNormalDisable,
                border: .clear,
                text: ColorSystem.labelNormalStrong,
                buttonBackground: ColorSystem.primaryStrong,
                buttonText: ColorSystem.labelWhite,
                alretText: ColorSystem.labelNormalBasic,
                isButtonEnabled: true
            )
        case .checking:
            return NicknameStyle(
                background: ColorSystem.labelNormalDisable,
                border: .clear,
                text: ColorSystem.labelNormalStrong,
                buttonBackground: ColorSystem.labelNormalAlternative,
                buttonText: ColorSystem.labelNormalBasic,
                alretText: ColorSystem.labelNormalBasic,
                isButtonEnabled: false
            )
        case .valid:
            return NicknameStyle(
                background: ColorSystem.semanticPositiveNormal,
                border: ColorSystem.primaryStrong,
                text: ColorSystem.semanticPositiveHeavy,
                buttonBackground: ColorSystem.labelNormalAlternative,
                buttonText: ColorSystem.labelNormalBasic,
                alretText: ColorSystem.semanticPositiveHeavy,
                isButtonEnabled: false
            )
        case .invalidFormat, .invalidDuplicate:
            return NicknameStyle(
                background: ColorSystem.semanticNegativeNormal,
                border: ColorSystem.semanticNegativeHeavy,
                text: ColorSystem.semanticNegativeHeavy,
                buttonBackground: ColorSystem.labelNormalAlternative,
                buttonText: ColorSystem.labelNormalBasic,
                alretText: ColorSystem.semanticNegativeHeavy,
                isButtonEnabled: false
            )
        }
    }
}
