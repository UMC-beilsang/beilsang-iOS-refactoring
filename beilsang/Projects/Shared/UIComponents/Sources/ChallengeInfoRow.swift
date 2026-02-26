//
//  ChallengeInfoRow.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 9/9/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeInfoRow<Content: View>: View {
    private let title: String
    private let content: () -> Content
    private let titleWidth: CGFloat
    
    public init(
        title: String,
        titleWidth: CGFloat = 70,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.titleWidth = titleWidth
        self.content = content
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 20) {
            Text(title)
                .fontStyle(Fonts.body1SemiBold)
                .foregroundColor(ColorSystem.labelNormalNormal)
                .frame(width: titleWidth, alignment: .leading)
            
            content()
        }
    }
}
