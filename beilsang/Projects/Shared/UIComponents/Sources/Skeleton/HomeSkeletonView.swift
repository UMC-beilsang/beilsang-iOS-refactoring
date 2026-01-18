//
//  HomeSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct HomeSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 20)
            
            // 배너 스켈레톤
            RoundedRectangle(cornerRadius: 24)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(height: UIScreen.main.bounds.height * 0.26)
                .shimmer()
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 24)
            
            // 카테고리 그리드 스켈레톤
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(
                    rows: [
                        GridItem(.fixed(80), spacing: 8),
                        GridItem(.fixed(80), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    ForEach(0..<8, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(width: 80, height: 80)
                            .shimmer()
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer().frame(height: 20)
            
            Rectangle()
                .fill(ColorSystem.labelNormalAssistive)
                .frame(height: 8)
            
            // 참여 중인 챌린지 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 0) {
                // 섹션 제목 스켈레톤
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 120, height: 20)
                        .shimmer()
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                Spacer().frame(height: 20)
                
                // 챌린지 카드 스켈레톤
                HStack(spacing: 14) {
                    ForEach(0..<2, id: \.self) { _ in
                        ChallengeItemSkeletonView(style: .grid)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer().frame(height: 40)
            
            // 추천 챌린지 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 0) {
                // 섹션 제목 스켈레톤
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 140, height: 20)
                        .shimmer()
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                // 챌린지 카드 스켈레톤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { _ in
                            ChallengeItemSkeletonView(style: .grid)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

