//
//  CategorySmallButton.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 9/9/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct CategorySmallButton: View {
    private let keyword: Keyword
    private let isSelected: Bool
    private let action: () -> Void
    
    public init(keyword: Keyword, isSelected: Bool = false, action: @escaping () -> Void) {
        self.keyword = keyword
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(keyword.iconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Text(keyword.title)
                    .fontStyle(.body1SemiBold)
                    .foregroundStyle(textColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(minWidth: 100)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1.25)
            )
            .cornerRadius(12)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Style Logic
private extension CategorySmallButton {
    var backgroundColor: Color {
        isSelected ? ColorSystem.primaryAlternative : Color.clear
    }
    
    var borderColor: Color {
        ColorSystem.lineNormal
    }
    
    var textColor: Color {
        ColorSystem.labelNormalNormal
    }
    
}

#Preview {
    VStack(spacing: 12) {
        CategorySmallButton(keyword: .plogging, isSelected: false) {
            print("플로깅 클릭")
        }
        CategorySmallButton(keyword: .bicycle, isSelected: true) {
            print("자전거 클릭")
        }
    }
    .padding()
    .background(ColorSystem.labelWhite)
    .previewLayout(.sizeThatFits)
}
