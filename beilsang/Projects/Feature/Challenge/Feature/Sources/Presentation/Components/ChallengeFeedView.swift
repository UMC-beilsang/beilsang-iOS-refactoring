//
//  ChallengeFeedView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared

struct ChallengeFeedView: View {
    let thumbnails: [ChallengeFeedThumbnail]
    let onThumbnailTap: (ChallengeFeedThumbnail) -> Void
    let onSeeAllTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("인증 갤러리")
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.labelNormalStrong)
                    
                    Text("참여자들의 인증 사진을 확인해 보세요!")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
                Spacer()
                Button(action: onSeeAllTap) {
                    HStack(spacing: 4) {
                        Text("전체보기")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                        
                        Image("caretIcon", bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                }
            }
            
            // Thumbnails
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14),
                          GridItem(.flexible(), spacing: 14)],
                spacing: 14
            ) {
                ForEach(thumbnails.prefix(4)) { thumbnail in
                    FeedThumbnailCard(
                        imageUrl: thumbnail.feedUrl,
                        isMyFeed: thumbnail.isMyFeed
                    ) {
                        onThumbnailTap(thumbnail)
                    }
                }
            }
        }
        .padding(.top, 28)
    }
}
