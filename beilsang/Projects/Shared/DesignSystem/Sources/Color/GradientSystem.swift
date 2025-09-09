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
}
