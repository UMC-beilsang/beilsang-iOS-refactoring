//
//  FeedsCard.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/31/25.
//


import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared

public struct FeedCard: View {
    private let feed: DiscoverFeed
    private let action: (() -> Void)?
    
    public init(feed: DiscoverFeed, action: (() -> Void)? = nil) {
        self.feed = feed
        self.action = action
    }
    
    public var body: some View {
        Button(action: { action?() }) {
            Group {
                if feed.feedUrl.hasPrefix("http") {
                    CachedAsyncImage(url: feed.feedUrl) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(ColorSystem.lineNeutral)
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
        }
        .buttonStyle(.plain)
    }
}
