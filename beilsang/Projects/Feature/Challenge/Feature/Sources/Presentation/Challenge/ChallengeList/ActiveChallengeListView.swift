//
//  ActiveChallengeListView.swift
//  ChallengeFeature
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import ChallengeDomain

public struct ActiveChallengeListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: ChallengeCoordinator
    @StateObject private var viewModel: ActiveChallengeListViewModel

    public init(viewModel: ActiveChallengeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .tertiaryAdd(
                title: "참여 중인 챌린지",
                onBack: { dismiss() },
                onAdd: { coordinator.navigateToCreate() },
                onSearch: { coordinator.presentSearch() }
            ))

            // 필터 바 고정
            filterBar
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    if viewModel.isLoading {
                        ChallengeListSkeletonView()
                            .transition(.opacity)
                    }

                    if !viewModel.isLoading {
                        VStack(alignment: .leading, spacing: 0) {
                            if viewModel.items.isEmpty {
                                emptyView.padding(.top, 60)
                            } else {
                                challengeListSection
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
            .overlay(alignment: .top) {
                topFadeGradient
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterBottomSheet(
                selectedFilter: viewModel.selectedFilter,
                onFilterSelected: { filter in
                    Task { await viewModel.applyFilter(filter) }
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            KeyboardDismiss.perform()
        }
        .task {
            if viewModel.items.isEmpty {
                await viewModel.load()
            }
        }
    }

    // MARK: - Fade Gradient

    private var topFadeGradient: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 20)
        .allowsHitTesting(false)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack {
            Button {
                viewModel.showFilterSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image("filterIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text(viewModel.selectedFilter.rawValue)
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(ColorSystem.labelNormalDisable)
                .clipShape(RoundedRectangle(cornerRadius: 999))
            }
            Spacer()
        }
    }

    // MARK: - List

    private var challengeListSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.items) { item in
                ChallengeItemView(
                    title: item.title,
                    imageUrl: item.thumbnailImageUrl,
                    style: .progressList(
                        progress: item.progressText,
                        author: item.author ?? ""
                    ),
                    isRecruitmentClosed: item.isRecruitmentClosed
                ) {
                    coordinator.navigateToDetail(id: item.id)
                }
            }
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("현재 참여 중인 챌린지가 없어요")
                .fontStyle(.body1SemiBold)
                .foregroundStyle(ColorSystem.labelNormalNormal)
            ActiveButton(title: "챌린지 둘러보기") {
                coordinator.navigateToChallengeList(category: .all)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
