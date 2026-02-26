//
//  NextStepButton.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared

public struct NextStepButton: View {
    private let title: String
    private let isEnabled: Bool
    private let onTap: () -> Void
    private let onDisabledTap: (() -> Void)?
    
    public init(
        title: String,
        isEnabled: Bool,
        onTap: @escaping () -> Void,
        onDisabledTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.onTap = onTap
        self.onDisabledTap = onDisabledTap
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                onTap()
            } else {
                onDisabledTap?()
            }
        }) {
            Text(title)
                .fontStyle(Fonts.heading2Bold)
                .foregroundStyle(isEnabled ? ColorSystem.labelWhite : ColorSystem.labelNormalBasic)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isEnabled ? ColorSystem.primaryStrong : ColorSystem.labelNormalAlternative)
                )
        }
    }
}
