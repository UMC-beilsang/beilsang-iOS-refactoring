//
//  SignupNextButton.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

public struct SignupNextButton: View {
    public let title: String
    public let isEnabled: Bool
    public let onTap: () -> Void
    public let onDisabledTap: (() -> Void)?
    
    public init(title: String, isEnabled: Bool, onTap: @escaping () -> Void, onDisabledTap: (() -> Void)? = nil) {
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
