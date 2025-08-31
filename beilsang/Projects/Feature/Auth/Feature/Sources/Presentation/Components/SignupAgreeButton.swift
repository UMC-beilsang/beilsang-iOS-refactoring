//
//  SignupAgreeButton.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

struct SignupAgreeButton: View {
    let title: String
    let isRequired: Bool
    let isChecked: Bool
    let onTap: () -> Void
    let onShowTerms: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Image(isChecked ? "agreeCheckIconSelected" : "agreeCheckIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    
                    Text(isRequired ? "필수" : "선택")
                        .fontStyle(Fonts.detail1Medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isRequired ? ColorSystem.primaryStrong : ColorSystem.primaryAlternative)
                        .foregroundColor(isRequired ? ColorSystem.labelWhite : ColorSystem.primaryStrong)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text(title)
                        .fontStyle(Fonts.body1SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                }
            }
            
            Spacer()
            
            if let onShowTerms = onShowTerms {
                Button(action: onShowTerms) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ColorSystem.labelNormalAlternative)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
    }
}
