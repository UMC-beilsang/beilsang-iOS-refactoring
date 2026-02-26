//
//  SearchResultsSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct SearchResultsSkeletonView: View {
    public enum Style {
        case challenge
        case feed
    }
    
    let style: Style
    
    public init(style: Style) {
        self.style = style
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                switch style {
                case .challenge:
                    // 챌린지 리스트 스켈레톤 (세로로 긴 직사각형)
                    LazyVStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { _ in
                            ChallengeItemSkeletonView(style: .list)
                        }
                    }
                    .padding(.top, 20)
                    
                case .feed:
                    // 피드 그리드 스켈레톤 (2열 그리드)
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ],
                        spacing: 14
                    ) {
                        ForEach(0..<8, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorSystem.labelNormalAssistive)
                                .aspectRatio(1, contentMode: .fit)
                                .shimmer()
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

