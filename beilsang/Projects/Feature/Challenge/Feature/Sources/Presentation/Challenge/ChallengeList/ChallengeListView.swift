//
//  ChallengeListView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/30/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import ChallengeDomain

struct ChallengeListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChallengeListViewModel
    
    let category: Keyword
    let onChallengeSelected: (String) -> Void
    let onBannerTapped: () -> Void
    
    init(
        category: Keyword,
        repository: ChallengeRepositoryProtocol,
        onChallengeSelected: @escaping (String) -> Void,
        onBannerTapped: @escaping () -> Void
    ) {
        self.category = category
        _viewModel = StateObject(wrappedValue: ChallengeListViewModel(repository: repository))
        self.onChallengeSelected = onChallengeSelected
        self.onBannerTapped = onBannerTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            Header(type: .tertiaryReport(
                title: category.title,
                onBack: { dismiss() },
                onOption: {
                    // TODO: - 신고/공유 액션
                }
            ))
            
            // MARK: - Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 배너
                    bannerSection
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                    
                    // 챌린지 리스트
                    challengeListSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchChallenges(for: category)
        }
    }
    
    // MARK: - Banner Section
    private var bannerSection: some View {
        Button(action: {
            onBannerTapped()
        }) {
            Image("listBannerIcon", bundle: .designSystem)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Challenge List Section
    private var challengeListSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.items) { item in
                ChallengeItemView(
                    title: item.title,
                    imageUrl: item.thumbnailImageUrl,
                    style: .progressList(progress: item.progressText, author: item.author ?? "익명")
                ) {
                    onChallengeSelected(item.id) 
                }
            }
        }
    }
}

