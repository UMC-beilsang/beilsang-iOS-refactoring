
//
//  ChallengeListSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeListSkeletonView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 배너 스켈레톤
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .shimmer()
                .padding(.top, 20)
                .padding(.bottom, 32)
            
            // 챌린지 리스트 스켈레톤
            VStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    ChallengeItemSkeletonView(style: .list)
                }
            }
        }
    }
}

