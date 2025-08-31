//
//  SignupNextButton.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

struct SignupNextButton: View {
    let title: String
    let isEnabled: Bool
    let onTap: () -> Void
    let onDisabledTap: (() -> Void)?
    
    var body: some View {
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
