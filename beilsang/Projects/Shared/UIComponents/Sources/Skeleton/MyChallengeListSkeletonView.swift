//
//  MyChallengeListSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct MyChallengeListSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 제목 스켈레톤
            RoundedRectangle(cornerRadius: 4)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(width: 120, height: 28)
                .shimmer()
                .padding(.horizontal, 24)
                .padding(.top, 32)
            
            // 챌린지 리스트 스켈레톤
            LazyVStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { _ in
                    ChallengeItemSkeletonView(style: .list)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

