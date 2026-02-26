//
//  FeedsCard.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/31/25.
//


import SwiftUI
import DesignSystemShared
import ModelsShared

public struct FeedCard: View {
    private let feed: ChallengeFeedDetail
    private let action: (() -> Void)?
    
    public init(feed: ChallengeFeedDetail, action: (() -> Void)? = nil) {
        self.feed = feed
        self.action = action
    }
    
    public var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Feed Image
                Group {
                    if feed.feedUrl.hasPrefix("http"),
                       let url = URL(string: feed.feedUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(ColorSystem.lineNeutral)
                        }
                    } else {
                        Image(feed.feedUrl, bundle: .designSystem)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                
                // MARK: - User Info
                HStack(spacing: 8) {
                    // 프로필 이미지 (임시 Circle placeholder)
                    Circle()
                        .fill(ColorSystem.lineNeutral)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feed.userName)
                            .fontStyle(.body2SemiBold)
                            .foregroundStyle(ColorSystem.labelNormalStrong)
                        
                        Text("\(feed.day)일차")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                    }
                    
                    Spacer()
                    
                    // 좋아요
                    HStack(spacing: 4) {
                        Image(systemName: feed.isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(feed.isLiked ? ColorSystem.primaryStrong : ColorSystem.labelNormalBasic)
                        Text("\(feed.likeCount)")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                    }
                }
                
                // MARK: - Description
                if !feed.description.isEmpty {
                    Text(feed.description)
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalStrong)
                        .lineLimit(2)
                }
                
                // MARK: - Tags
                if !feed.challengeTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(feed.challengeTags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .fontStyle(.detail1Medium)
                                    .foregroundStyle(ColorSystem.primaryStrong)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(ColorSystem.primaryStrong)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(ColorSystem.labelNormalAlternative)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
