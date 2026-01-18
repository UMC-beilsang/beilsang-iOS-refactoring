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
            VStack(alignment: .leading, spacing: 20) {
                // 인사말 스켈레톤
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 200, height: 28)
                    .shimmer()
                
                HStack(alignment: .center, spacing: 20) {
                    // 프로필 이미지 스켈레톤
                    Circle()
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 88, height: 88)
                        .shimmer()
                    
                    // 통계 스켈레톤 (3개 작은 박스)
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorSystem.labelNormalAssistive)
                                .frame(width: 60, height: 60)
                                .shimmer()
                        }
                    }
                }
                
                // 큰 박스 (다짐 카드)
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(height: 60)
                    .shimmer()
                
                // 작은 박스 (프로필 수정 버튼)
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 100, height: 20)
                        .shimmer()
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
                // 섹션 제목 스켈레톤
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 100, height: 28)
                    .shimmer()
                
                // 큰 박스 (챌린지 통계 카드)
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(height: 100)
                    .shimmer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            // 나의 챌린지 피드 섹션 스켈레톤
            VStack(alignment: .leading, spacing: 16) {
                // 섹션 제목 스켈레톤
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 120, height: 28)
                    .shimmer()
                
                // 2개의 큰 박스 나란히
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(height: 200)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(height: 200)
                        .shimmer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 100)
        }
    }
}

