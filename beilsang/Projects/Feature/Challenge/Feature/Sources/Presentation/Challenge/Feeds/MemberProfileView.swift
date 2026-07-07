//
//  MemberProfileView.swift
//  ChallengeFeature
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import UtilityShared

public struct MemberProfileView<FeedDetailView: View>: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MemberProfileViewModel

    private let feedDetailViewBuilder: (Int) -> FeedDetailView

    public init(
        viewModel: MemberProfileViewModel,
        @ViewBuilder feedDetailViewBuilder: @escaping (Int) -> FeedDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.feedDetailViewBuilder = feedDetailViewBuilder
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profileSection

                sectionDivider

                VStack(alignment: .leading, spacing: 32) {
                    if !viewModel.activityBadges.isEmpty {
                        activityBadgesSection
                    }

                    if !viewModel.challengeBadges.isEmpty {
                        challengeBadgesSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
            .padding(.bottom, 40)
        }
        .background(ColorSystem.backgroundNormalNormal)
        .safeAreaInset(edge: .top) {
            Header(type: .secondary(
                title: "챌린저 프로필",
                onBack: { dismiss() }
            ))
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(ColorSystem.labelNormalDisable)
            .frame(height: 8)
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text(viewModel.memberInfo.nickName ?? "닉네임")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)

            HStack(alignment: .center) {
                CachedAsyncImage(url: viewModel.memberInfo.profileImage) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("profilePlaceholderImage", bundle: .designSystem)
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 88, height: 88)
                .clipShape(Circle())

                Spacer()

                HStack(spacing: 0) {
                    statItem(title: "피드", value: viewModel.feedCount)
                        .frame(maxWidth: .infinity)

                    statItem(title: "달성", value: viewModel.successCount)
                        .frame(maxWidth: .infinity)

                    statItem(title: "실패", value: viewModel.failedCount)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 32)
    }

    private func statItem(title: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .fontStyle(.body1Medium)
                .foregroundStyle(ColorSystem.labelNormalNormal)
            Text("\(value)개")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.primaryStrong)
        }
    }

    // MARK: - Activity Badges Section
    private var activityBadgesSection: some View {
        VStack(alignment: .leading, spacing: 36) {
            sectionHeader(title: "활동 배지", count: viewModel.activityBadges.count)
            badgeGrid(viewModel.activityBadges, usePngBackground: false)
        }
    }

    // MARK: - Challenge Badges Section
    private var challengeBadgesSection: some View {
        VStack(alignment: .leading, spacing: 36) {
            sectionHeader(title: "챌린지 배지", count: viewModel.challengeBadges.count)
            badgeGrid(viewModel.challengeBadges, usePngBackground: true)
        }
    }

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)

            Text("\(count)")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.primaryStrong)
        }
    }

    private func badgeGrid(_ badges: [ProfileBadge], usePngBackground: Bool) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 40),
                GridItem(.flexible(), spacing: 40),
                GridItem(.flexible(), spacing: 40)
            ],
            spacing: 40
        ) {
            ForEach(badges) { badge in
                badgeItemView(badge, usePngBackground: usePngBackground)
            }
        }
    }

    private func badgeItemView(_ badge: ProfileBadge, usePngBackground: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                if usePngBackground {
                    Image("badgeBackground", bundle: .designSystem)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(ColorSystem.backgroundNormalAlternative)
                        .frame(width: 84, height: 84)
                }

                Image(badge.iconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            .frame(width: 84, height: 84)

            Text(badge.title)
                .fontStyle(.detail2Regular)
                .foregroundStyle(ColorSystem.labelNormalNormal)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }

}
