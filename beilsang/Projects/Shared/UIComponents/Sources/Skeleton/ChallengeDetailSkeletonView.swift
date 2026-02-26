//
//  ChallengeDetailSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeDetailSkeletonView: View {
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 이미지 영역
                        Rectangle()
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(height: UIScreen.main.bounds.height * 0.32)
                            .shimmer()
                        
                        // 섹션 1: 제목, 카테고리, 정보
                        VStack(alignment: .leading, spacing: 0) {
                            // 제목 스켈레톤 (ChallengeTitleView - spacing: 8, padding top: 32, padding bottom: 20)
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(width: 200, height: 28)
                                    .shimmer()
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(width: 150, height: 16)
                                    .shimmer()
                            }
                            .padding(.top, 32)
                            .padding(.bottom, 20)
                            
                            // 카테고리 버튼 스켈레톤 (CategorySmallButton - padding vertical: 12, horizontal: 16)
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorSystem.labelNormalAssistive)
                                .frame(width: 100, height: 44)
                                .shimmer()
                            
                            // 정보 영역 스켈레톤 (ChallengeInfoView - spacing: 24, padding top: 32)
                            VStack(alignment: .leading, spacing: 24) {
                                // ChallengeInfoRow 2개 (spacing: 12)
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(0..<2, id: \.self) { _ in
                                        HStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(ColorSystem.labelNormalAssistive)
                                                .frame(width: 60, height: 16)
                                                .shimmer()
                                            
                                            Spacer()
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(ColorSystem.labelNormalAssistive)
                                                .frame(width: 120, height: 16)
                                                .shimmer()
                                        }
                                    }
                                }
                                
                                // ChallengeWeeklyGoalView 스켈레톤 (padding vertical: 20, horizontal: 20)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(height: 80)
                                    .shimmer()
                            }
                            .padding(.top, 32)
                        }
                        .padding(.horizontal, 24)
                        
                        // 구분선
                        Rectangle()
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(height: 8)
                            .padding(.top, 24)
                        
                        // 섹션 2: 설명 및 인증 정보 (VStack spacing: 0)
                        VStack(alignment: .leading, spacing: 0) {
                            // 설명 스켈레톤 (ChallengeDescriptionView - spacing: 12, padding top: 28)
                            VStack(alignment: .leading, spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(width: 80, height: 20)
                                    .shimmer()
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(height: 100)
                                    .shimmer()
                            }
                            .padding(.top, 28)
                            
                            // 인증 이미지 스켈레톤 (ChallengeCertInfoView - spacing: 12, padding top: 28)
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ColorSystem.labelNormalAssistive)
                                        .frame(width: 140, height: 20)
                                        .shimmer()
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ColorSystem.labelNormalAssistive)
                                        .frame(width: 200, height: 14)
                                        .shimmer()
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(ColorSystem.labelNormalAssistive)
                                                .frame(width: 120, height: 120)
                                                .shimmer()
                                        }
                                    }
                                }
                            }
                            .padding(.top, 28)
                            
                            // 보증금 정보 스켈레톤 (ChallengeDepositInfoView - spacing: 12, padding top: 28)
                            VStack(alignment: .leading, spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(width: 120, height: 20)
                                    .shimmer()
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ColorSystem.labelNormalAssistive)
                                    .frame(height: 120)
                                    .shimmer()
                            }
                            .padding(.top, 28)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                            .frame(minHeight: UIScreen.main.bounds.height * 0.21)
                    }
                }
            }
            
            // 하단 버튼 스켈레톤 (ChallengeBottomButton)
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    // 좋아요 버튼 스켈레톤
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(width: 28, height: 28)
                            .shimmer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorSystem.labelNormalAssistive)
                            .frame(width: 20, height: 16)
                            .shimmer()
                    }
                    
                    Spacer()
                    
                    // 메인 버튼 스켈레톤
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorSystem.labelNormalAssistive)
                        .frame(width: UIScreen.main.bounds.width * 0.5, height: 52)
                        .shimmer()
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 24,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: 24
                        )
                    )
                    .fill(ColorSystem.labelWhite)
                    .shadow(
                        color: ColorSystem.decorateShadowNormal,
                        radius: 7,
                        x: 0, y: 0
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.13)
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

