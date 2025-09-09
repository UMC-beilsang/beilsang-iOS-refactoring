//
//  ChallengeCertView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeCertView: View {
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
            
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(Array(certImages.enumerated()), id: \.offset) { index, url in
                            // TODO: - URL이미지 사용
                            Image(url, bundle: .designSystem)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.height * 0.17,
                                       height: UIScreen.main.bounds.height * 0.17)
                                .clipped()
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Text("챌린지 가이드 내용")
                    .fontStyle(.body2SemiBold)
                    .foregroundStyle(ColorSystem.labelNormalNormal)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalDisable)
            )
        }
        .padding(.top, 28)
    }
}
