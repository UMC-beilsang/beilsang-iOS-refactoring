//
//  ChallengeRecommendView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import ChallengeDomain

struct ChallengeRecommendView: View {
    let recommendChallenges: [ChallengeItem]
    let showOnlyFirst: Bool
    
    init(recommendChallenges: [ChallengeItem], showOnlyFirst: Bool = false) {
        self.recommendChallenges = recommendChallenges
        self.showOnlyFirst = showOnlyFirst
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("이런 챌린지는 어때요?")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            VStack(spacing: 8) {
                let challengesToShow = showOnlyFirst ? Array(recommendChallenges.prefix(1)) : recommendChallenges
                
                ForEach(challengesToShow, id: \.id) { challenge in
                    ChallengeRecommendItemView(challenge: challenge)
                }
            }
        }
        .padding(.top, 28)
    }
}

struct ChallengeRecommendItemView: View {
    let challenge: ChallengeItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            CachedAsyncImage(url: challenge.imageUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(width: UIScreen.main.bounds.height * 0.07, height: UIScreen.main.bounds.height * 0.07)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                if let keyword = Keyword(rawValue: challenge.category) {
                    Text("\(keyword.title) 챌린지")
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.primaryStrong)
                }
                
                Text(challenge.title)
                    .fontStyle(.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorSystem.labelNormalDisable)
        )
    }
}
