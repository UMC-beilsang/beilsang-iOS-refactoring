//
//  ChallengeTitleView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeTitleView: View {
    let title: String
    let startDateText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 32)
            
            if !startDateText.isEmpty {
                Text(startDateText)
                    .padding(.bottom, 20)
                    .fontStyle(.body2Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
        }
    }
}
