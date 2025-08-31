//
//  SocialLoginButton.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import DesignSystemShared

enum SocialLoginType {
    case kakao
    case apple
    
    var title: String {
        switch self {
        case .kakao:
            return "카카오톡으로 시작하기"
        case .apple:
            return "Apple로 시작하기"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .kakao:
            return ColorSystem.brandKakaoContainer
        case .apple:
            return ColorSystem.labelBlack
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .kakao:
            return ColorSystem.brandKakaoLabel
        case .apple:
            return ColorSystem.labelWhite
        }
    }
    
    var iconName: String {
        switch self {
        case .kakao:
            return "message.fill"
        case .apple:
            return "apple.logo"
        }
    }
}

struct SocialLoginButton: View {
    let type: SocialLoginType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(type.title)
                    .fontStyle(.heading3SemiBold)
                    .foregroundColor(type.foregroundColor)
                    .frame(maxWidth: .infinity)

                HStack {
                    Image(systemName: type.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(type.foregroundColor)
                        .frame(width: 24, height: 24)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(type.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(ColorSystem.lineNormal, lineWidth: 1.25)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
