//
//  TextFieldState+Style.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public extension TextFieldState {
    var textColor: Color {
        switch self {
        case .invalidFormat: return ColorSystem.semanticNegativeHeavy
        case .valid: return ColorSystem.semanticPositiveHeavy
        default: return ColorSystem.labelNormalStrong
        }
    }
    
    var alertTextColor: Color {
        switch self {
        case .invalidFormat: return ColorSystem.semanticNegativeHeavy
        case .valid: return ColorSystem.semanticPositiveHeavy
        default: return ColorSystem.labelNormalBasic
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .valid: return ColorSystem.semanticPositiveNormal
        case .invalidFormat: return ColorSystem.semanticNegativeNormal
        default: return ColorSystem.labelNormalDisable
        }
    }
    
    var borderColor: Color {
        switch self {
        case .valid: return ColorSystem.primaryStrong
        case .invalidFormat: return ColorSystem.semanticNegativeHeavy
        case .focused, .typing: return ColorSystem.primaryStrong
        default: return Color.clear
        }
    }
}
