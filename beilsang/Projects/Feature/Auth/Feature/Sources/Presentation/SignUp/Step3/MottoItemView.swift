//
//  MottoItemView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

struct MottoItemView: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let hasAnySelection: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Image(currentIconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Spacer()
                    .frame(width: 12)
                
                Text(title)
                    .fontStyle(Fonts.heading3Bold)
                    .foregroundStyle(textColor)
                
                Spacer()
                
                Image(checkIconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorSystem.labelNormalDisable)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? ColorSystem.primaryStrong : .clear, lineWidth: 2.75)
                    )
            )
        }
    }
    
    private var currentIconName: String {
        if isSelected { return iconName }
        if !hasAnySelection { return iconName }
        return iconName + "Default"
    }
    
    private var textColor: Color {
        if hasAnySelection {
            return isSelected ? ColorSystem.primaryHeavy : ColorSystem.labelNormalBasic
        } else {
            return ColorSystem.labelNormalStrong
        }
    }
    
    private var checkIconName: String {
        if isSelected {
            return "primaryCheckIcon"
        } else {
            return "nonprimaryCheckIcon"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MottoItemView(
            title: "환경보호에 앞장서는 나",
            iconName: "ecoLeaderIcon",
            isSelected: true,
            hasAnySelection: true,
            onTap: {}
        )
        MottoItemView(
            title: "일상생활 속 꾸준하게 실천하는 나",
            iconName: "dailyPracticeIcon",
            isSelected: false,
            hasAnySelection: true,
            onTap: {}
        )
        MottoItemView(
            title: "자연과의 조화를 이루는 나",
            iconName: "harmonyIcon",
            isSelected: false,
            hasAnySelection: false,
            onTap: {}
        )
    }
    .padding()
}
