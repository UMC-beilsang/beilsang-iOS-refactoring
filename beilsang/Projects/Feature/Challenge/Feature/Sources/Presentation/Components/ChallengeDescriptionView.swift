//
//  ChallengeDescriptionView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeDescriptionView: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("세부 설명")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            Text(description)
                .fontStyle(.body2SemiBold)
                .foregroundStyle(ColorSystem.labelNormalNormal)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorSystem.labelNormalDisable)
                )
        }
        .padding(.top, 28)
    }
}

