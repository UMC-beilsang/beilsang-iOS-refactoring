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
    let createdAtText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 32)
            
            HStack(spacing: 8) {
                // TODO: - 작성자명 추가
                Text("작성자명")
                
                Text("|")
                
                Text(createdAtText)
            }
            .padding(.bottom, 20)
            .fontStyle(.body2Medium)
            .foregroundStyle(ColorSystem.labelNormalBasic)
        }
    }
}
