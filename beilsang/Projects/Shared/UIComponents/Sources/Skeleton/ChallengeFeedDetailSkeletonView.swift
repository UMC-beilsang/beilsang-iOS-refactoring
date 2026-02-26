//
//  ChallengeFeedDetailSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeFeedDetailSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 사용자 프로필 영역 스켈레톤
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 20) {
                    // 프로필 이미지 스켈레톤
                    Circle()
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 52, height: 52)
                        .shimmer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // 사용자 이름 스켈레톤
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(width: 100, height: 20)
                            .shimmer()
                        
                        // 생성 시간 스켈레톤
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(width: 80, height: 16)
                            .shimmer()
                    }
                    
                    Spacer()
                }
                .padding(.top, 24)
                
                // 피드 이미지 스켈레톤
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorSystem.labelNormalAssistive)
                    .aspectRatio(1.5, contentMode: .fit)
                    .shimmer()
                
                // 좋아요 버튼 스켈레톤
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 80, height: 28)
                        .shimmer()
                    
                    Spacer()
                }
                
                // 피드 설명 스켈레톤
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: UIScreen.main.bounds.width - 88, height: 16)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: UIScreen.main.bounds.width - 88, height: 16)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 150, height: 16)
                        .shimmer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorSystem.labelNormalDisable)
                )
                
                // 챌린지 태그 스켈레톤
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 999)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 80, height: 26)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 999)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: 100, height: 26)
                        .shimmer()
                    
                    Spacer()
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
            
            // Divider
            Rectangle()
                .fill(ColorSystem.labelNormalDisable)
                .frame(height: 8)
                .padding(.top, 40)
        }
    }
}

