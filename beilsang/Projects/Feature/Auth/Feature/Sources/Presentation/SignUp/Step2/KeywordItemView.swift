//
//  KeywordItemView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/29/25.
//

import SwiftUI
import DesignSystemShared

struct KeywordItemView: View {
    let title: String
    let defaultIconName: String
    let selectedIconName: String
    let isSelected: Bool
    let hasAnySelection: Bool
    let onTap: () -> Void
    let itemSize: CGFloat
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(currentIconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: itemSize * 0.4, height: itemSize * 0.4) 
                
                Text(title)
                    .fontStyle(Fonts.body1SemiBold)
                    .foregroundStyle(ColorSystem.labelNormalNormal)
            }
            .frame(width: itemSize, height: itemSize)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorSystem.labelNormalDisable)
            )
        }
    }
    
    private var currentIconName: String {
        if isSelected { return selectedIconName }
        if !hasAnySelection { return selectedIconName }
        return defaultIconName
    }
}
