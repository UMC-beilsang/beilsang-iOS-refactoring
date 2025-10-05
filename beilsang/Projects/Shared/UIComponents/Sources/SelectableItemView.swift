//
//  SelectableItemView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/4/25.
//

import SwiftUI
import DesignSystemShared

public struct SelectableItemView: View {
    let title: String
    let iconName: String?
    let isSelected: Bool
    let hasAnySelection: Bool
    let onTap: () -> Void
    
    public init(
        title: String,
        iconName: String? = nil,
        isSelected: Bool,
        hasAnySelection: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isSelected = isSelected
        self.hasAnySelection = hasAnySelection
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                if let iconName = iconName {
                    Image(currentIconName, bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    
                    Spacer()
                        .frame(width: 12)
                }
                
                Text(title)
                    .fontStyle(.body1Bold)
                    .foregroundStyle(textColor)
                
                Spacer(minLength: 8)
                
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
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? ColorSystem.primaryStrong : .clear, lineWidth: 2.75)
            )
        }
    }
    
    private var currentIconName: String {
        guard let iconName = iconName else { return "" }
        
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
        // 아이콘 있는 버전 (모토 선택)
        SelectableItemView(
            title: "환경보호에 앞장서는 나",
            iconName: "ecoLeaderIcon",
            isSelected: true,
            hasAnySelection: true,
            onTap: {}
        )
        
        SelectableItemView(
            title: "일상생활 속 꾸준하게 실천하는 나",
            iconName: "dailyPracticeIcon",
            isSelected: false,
            hasAnySelection: true,
            onTap: {}
        )
        
        // 아이콘 없는 버전 (인증 방법 선택)
        SelectableItemView(
            title: "사진 인증",
            isSelected: true,
            hasAnySelection: true,
            onTap: {}
        )
        
        SelectableItemView(
            title: "텍스트 인증",
            isSelected: false,
            hasAnySelection: true,
            onTap: {}
        )
    }
    .padding()
}
