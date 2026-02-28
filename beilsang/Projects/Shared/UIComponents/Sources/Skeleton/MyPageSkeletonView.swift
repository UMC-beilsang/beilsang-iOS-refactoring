//
//  MyPageSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct MyPageSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 프로필 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 28) {
                // 인사말
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 200, height: 28)
                    .shimmer()
                
                HStack(alignment: .center) {
                    // 프로필 이미지
                    Circle()
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 88, height: 88)
                        .shimmer()
                    
                    Spacer()
                    
                    // 통계 3개 (피드, 달성, 실패)
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(width: 40, height: 20)
                                    .shimmer()
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(width: 30, height: 24)
                                    .shimmer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // 프로필 수정 버튼
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 6)
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(width: 100, height: 16)
                            .shimmer()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            
            // Divider
            Rectangle()
                .fill(ColorSystem.labelNormalDisable)
                .frame(height: 8)
            
            // 나의 챌린지 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 20) {
                // 섹션 제목
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 120, height: 28)
                    .shimmer()
                
                // 챌린지 통계 카드
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(height: 100)
                    .shimmer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            // 나의 챌린지 피드 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 16) {
                // 섹션 제목
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 150, height: 28)
                    .shimmer()
                    .padding(.horizontal, 24)
                
                // 피드 그리드 (2x2)
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
                            .aspectRatio(1, contentMode: .fit)
                            .shimmer()
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 32)
            .padding(.bottom, 100)
        }
    }
}

