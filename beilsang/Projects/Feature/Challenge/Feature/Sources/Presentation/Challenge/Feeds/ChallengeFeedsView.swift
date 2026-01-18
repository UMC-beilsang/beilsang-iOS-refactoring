//
//  ChallengeFeedsView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/16/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain

public struct ChallengeFeedsView: View {
    @StateObject private var viewModel: ChallengeFeedsViewModel
    @EnvironmentObject var coordinator: ChallengeCoordinator
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: ChallengeFeedsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .tertiaryReport(
                title: "인증 갤러리",
                onBack: { dismiss() },
                onOption: {}
            ))
            
            ScrollView {
                ZStack {
                    if viewModel.isLoading && viewModel.thumbnails.isEmpty {
                        ChallengeFeedsSkeletonView()
                            .transition(.opacity)
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 14),
                                GridItem(.flexible(), spacing: 14)
                            ],
                            spacing: 14
                        ) {
                            ForEach(viewModel.thumbnails.indices, id: \.self) { index in
                                let thumbnail = viewModel.thumbnails[index]
                                
                                FeedThumbnailCard(
                                    imageUrl: thumbnail.feedUrl,
                                    isMyFeed: thumbnail.isMyFeed
                                ) {
                                    viewModel.showFeedDetail(feedId: thumbnail.id)
                                }
                                .onAppear {
                                    if index == viewModel.thumbnails.count - 2 {
                                        Task { await viewModel.loadMoreFeeds() }
                                    }
                                }
                            }
                        }
                        .padding(.top, 30)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                        
                        if viewModel.isLoading && !viewModel.thumbnails.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.vertical, 20)
                                Spacer()
                            }
                        }
                    }
                }
                .animation(.easeOut(duration: 0.4), value: viewModel.isLoading)
            }
        }
        .task {
            if viewModel.thumbnails.isEmpty {
                await viewModel.loadFeeds(showSkeleton: true)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showFeedDetail) {
            if let feedId = viewModel.selectedFeedId {
                ChallengeFeedDetailView(
                    viewModel: ChallengeFeedDetailViewModel(
                        feedId: feedId,
                        repository: viewModel.repository
                    )
                )
            }
        }
    }
}
