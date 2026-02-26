//
//  BottomOverlayGradient 2.swift
//  DesignSystemShared
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI

public struct BottomOverlayGradient: View {
    public init() {}

    public var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ColorSystem.backgroundNormalNormal.opacity(0),
                ColorSystem.backgroundNormalNormal
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
