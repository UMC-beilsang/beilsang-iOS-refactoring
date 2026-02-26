//
//  ChallengeItemSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeItemSkeletonView: View {
    public enum Style {
        case grid
        case list
        
        var width: CGFloat {
            switch self {
            case .grid:
                return UIScreen.main.bounds.width / 2 - 31
            case .list:
                return UIScreen.main.bounds.width - 48
            }
        }
    }
    
    let style: Style
    
    public init(style: Style = .grid) {
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 이미지 영역
            UnevenRoundedRectangle(topLeadingRadius:20, topTrailingRadius: 20)
                .fill(ColorSystem.labelNormalAssistive)
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .shimmer()
            
            // 하단 정보 영역
            ZStack {
                Rectangle()
                    .fill(ColorSystem.labelNormalAssistive)
                
                HStack {
                    if style == .list {
                        UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                            .fill(ColorSystem.labelNormalAssistive.opacity(0.3))
                            .frame(width: 40, height: 12)
                    }
                    
                    Spacer()
                    
                    UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                        .fill(ColorSystem.labelNormalAssistive.opacity(0.3))
                        .frame(width: 60, height: 12)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
            }
            .frame(height: UIScreen.main.bounds.height * 0.04)
        }
        .frame(width: style.width)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

