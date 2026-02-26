//
//  DiscoverSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct DiscoverSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 명예의 전당 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 0) {
                // 섹션 제목 스켈레톤 
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 100, height: 28)
                    .shimmer()
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                
                // 카테고리 버튼 스켈레톤 (CategorySmallButton: padding vertical 12, horizontal 16, minWidth 100, cornerRadius 12)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<8, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorSystem.labelNormalAssistive)
                                .frame(width: 100, height: 48)
                                .shimmer()
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                
                // 명예의 전당 챌린지 카드 스켈레톤 (HonorsChallengeCard: 160x160, spacing 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorSystem.labelNormalAssistive)
                                .frame(width: 160, height: 160)
                                .shimmer()
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 12)
            }
            
            // 카테고리별 챌린지 피드 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 0) {
                // 섹션 제목 스켈레톤 (heading2Bold)
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 150, height: 28)
                    .shimmer()
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                
                // 카테고리 그리드 스켈레톤 (CategoryGridView singleRow: 80x80, spacing 10, cornerRadius 12)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<8, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorSystem.labelNormalAssistive)
                                .frame(width: 80, height: 80)
                                .shimmer()
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                
                // 피드 그리드 스켈레톤 (FeedThumbnailCard: aspectRatio 1.3, cornerRadius 16, spacing 14)
                VStack(alignment: .leading, spacing: 12) {
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
                    .padding(.top, 16)
                }
            }
        }
    }
}

