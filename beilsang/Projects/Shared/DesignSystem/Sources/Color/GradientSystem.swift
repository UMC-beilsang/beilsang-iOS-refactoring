//
//  GradientSystem.swift
//  DesignSystemShared
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI

public enum GradientSystem {
    public static let cardOverlay = LinearGradient(
        gradient: Gradient(colors: [
            Color.black.opacity(0.0),
            Color.black.opacity(0.3)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    public static let primaryBackground = LinearGradient(
        gradient: Gradient(colors: [
            ColorSystem.primaryAlternative,
            ColorSystem.primaryNeutral,
            ColorSystem.backgroundNormalNormal
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
