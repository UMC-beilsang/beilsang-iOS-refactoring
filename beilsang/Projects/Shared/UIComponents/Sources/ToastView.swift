//
//  ToastView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

public struct ToastView: View {
    let iconName: String?
    let message: String

    public init(iconName: String? = nil, message: String) {
        self.iconName = iconName
        self.message = message
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let iconName = iconName {
                Image(iconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            Text(message)
                .fontStyle(Fonts.body1SemiBold)
                .foregroundColor(ColorSystem.labelWhite)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(ColorSystem.decorateScrimNormal)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .cornerRadius(24)
        .frame(height: 48)
    }
}

