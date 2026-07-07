//
//  DiscoverView.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/8/25.
//

import SwiftUI
import ModelsShared
import NavigationShared
import UtilityShared
import DesignSystemShared
import UIComponentsShared

public struct DiscoverView: View {
    @EnvironmentObject var appRouter: AppRouter
    @ObservedObject var coordinator: DiscoverCoordinator
    @Environment(\.challengePresentationCoordinator) var challengePresentationCoordinator

    @StateObject private var viewModel: DiscoverViewModel

    public init(container: DiscoverContainer, coordinator: DiscoverCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: container.discoverViewModel)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Header(type: .primaryTitle(title: "발견", onNotification: {
                        challengePresentationCoordinator?.presentNotification()
                    }, onSearch: {
                        challengePresentationCoordinator?.presentSearch()
                    }))
                    
                    ZStack {
                        if viewModel.isInitialLoading {
                            DiscoverSkeletonView()
                                .transition(.opacity)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                honorsChallengeSection
                                keywordFeedsSection
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeOut(duration: 0.2), value: viewModel.isInitialLoading)
                }

                Spacer().frame(minHeight: 180)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // 데이터가 없을 때만 최초 로드 (스켈레톤)
            // 이미 데이터가 있으면 아무것도 안 함 → pull-to-refresh로 명시적 갱신
            if viewModel.honorsChallenges.isEmpty && viewModel.keywordFeeds.isEmpty {
                await viewModel.loadInitialData(keyword: viewModel.feedsSelectedKeyword, showSkeleton: true)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("확인")) { viewModel.clearError() }
            )
        }
    }

    // MARK: - Honors Challenge Section
    private var honorsChallengeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("명예의 전당")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 32)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Keyword.allCases, id: \.self) { keyword in
                        CategorySmallButton(
                            keyword: keyword,
                            isSelected: viewModel.honorsSelectedKeyword == keyword
                        ) {
                            Task { await viewModel.selectHonorsKeyword(keyword) }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 20)

            if viewModel.isHonorsSectionLoading {
                // 카테고리 전환 중 로딩 스켈레톤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorSystem.labelNormalDisable)
                                .frame(width: 160, height: 160)
                                .modifier(ShimmerModifier())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
            } else if let hallOfFame = viewModel.honorsChallenges[viewModel.honorsSelectedKeyword],
                      !hallOfFame.challenges.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(hallOfFame.challenges.enumerated()), id: \.element.id) { (index, challenge) in
                            HonorsChallengeCard(challenge: challenge, rank: index + 1) {
                                challengePresentationCoordinator?.presentChallenge(id: challenge.id)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
            } else {
                Text("해당 카테고리의 챌린지가 없습니다.")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
            }
        }
    }

    // MARK: - Keyword Feeds Section
    private var keywordFeedsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("카테고리별 챌린지 피드")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 32)
                .padding(.horizontal, 24)

            CategoryGridView(
                layout: .singleRow,
                selectedKeyword: viewModel.feedsSelectedKeyword
            ) { keyword in
                Task { await viewModel.selectFeedsKeyword(keyword) }
            }
            .padding(.top, 20)

            if viewModel.isFeedSectionLoading {
                // 카테고리 전환 중 그리드 스켈레톤
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14)
                    ],
                    spacing: 14
                ) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorSystem.labelNormalDisable)
                            .frame(height: 160)
                            .modifier(ShimmerModifier())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            } else if let state = viewModel.keywordFeeds[viewModel.feedsSelectedKeyword],
                      !state.feeds.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ],
                        spacing: 14
                    ) {
                        ForEach(state.feeds) { feed in
                            Button {
                                challengePresentationCoordinator?.presentFeed(id: feed.feedId)
                            } label: {
                                Group {
                                    if feed.feedUrl.hasPrefix("http") {
                                        CachedAsyncImage(url: feed.feedUrl) { image in
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
                                .frame(height: 160)
                                .clipped()
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if feed == state.feeds.last, state.hasNext {
                                    Task { await viewModel.loadNextFeeds(for: viewModel.feedsSelectedKeyword) }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    if viewModel.isLoadingMore {
                        DotsLoadingView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                    }
                }
            } else {
                Text("해당 카테고리의 피드가 없습니다.")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
            }
        }
    }
}
