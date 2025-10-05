//
//  ChallengeCertView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeCertInfoView: View {
    let certImages: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("챌린지 인증 유의사항")
                    .fontStyle(.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Text("아래 챌린지 모범 인증 사진을 확인해 보세요!")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
            
            GuideContentView(certImages: certImages)
        }
        .padding(.top, 28)
    }
}
