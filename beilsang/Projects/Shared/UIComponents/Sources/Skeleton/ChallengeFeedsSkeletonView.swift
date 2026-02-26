//
//  ChallengeFeedsSkeletonView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeFeedsSkeletonView: View {
    public init() {}
    
    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ],
            spacing: 14
        ) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorSystem.labelNormalAssistive)
                    .aspectRatio(1.3, contentMode: .fit)
                    .shimmer()
            }
        }
        .padding(.top, 30)
        .padding(.horizontal, 24)
    }
}

