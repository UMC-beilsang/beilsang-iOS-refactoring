//
//  MyFeedListSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct MyFeedListSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 제목 스켈레톤
            RoundedRectangle(cornerRadius: 4)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(width: 150, height: 28)
                .shimmer()
                .padding(.horizontal, 24)
                .padding(.top, 32)
            
            // 피드 그리드 스켈레톤 (2x2 그리드)
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorSystem.labelNormalAssistive)
                        .aspectRatio(1.3, contentMode: .fit)
                        .shimmer()
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

