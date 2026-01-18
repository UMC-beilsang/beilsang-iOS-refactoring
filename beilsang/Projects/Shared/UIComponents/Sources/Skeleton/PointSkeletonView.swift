//
//  PointSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct PointSkeletonView: View {
    public init() {}
    
    public var body: some View {
        // 포인트 값과 소멸 예정 포인트 카드만 스켈레톤
        VStack(alignment: .leading, spacing: 20) {
            // 포인트 값 스켈레톤 (작은 박스)
            RoundedRectangle(cornerRadius: 4)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(width: 150, height: 40)
                .shimmer()
            
            // 소멸 예정 포인트 카드 스켈레톤 (큰 박스)
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(height: 52)
                .shimmer()
        }
    }
}

// 포인트 내역 리스트 스켈레톤
public struct PointHistorySkeletonView: View {
    public init() {}
    
    public var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(height: 100)
                    .shimmer()
                    .padding(.horizontal, 24)
            }
        }
        .padding(.top, 12)
    }
}
