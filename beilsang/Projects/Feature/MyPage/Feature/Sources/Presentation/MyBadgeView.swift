//
//  MyBadgeView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared

public struct MyBadgeView: View {
    @ObservedObject private var viewModel: MyBadgeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBadge: BadgeItem?
    @State private var isShowingDetail: Bool = false
    
    public init(viewModel: MyBadgeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        MyBadgeScreenContent(viewModel: viewModel)
    }
    
}

// MARK: - 실제 배지 화면 구현
private struct MyBadgeScreenContent: View {
    @ObservedObject var viewModel: MyBadgeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBadge: BadgeItem?
    @State private var isShowingDetail: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Header(type: .secondary(
                title: "나의 배지",
                onBack: { dismiss() }
            ))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    representativeBadgeSection
                    activityBadgeSection
                    challengeBadgeSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
            .background(ColorSystem.backgroundNormalNormal)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingDetail) {
            if let badge = selectedBadge {
                BadgeDetailView(
                    badge: badge,
                    isRepresentative: viewModel.representativeBadge?.id == badge.id,
                    onSetRepresentative: {
                        viewModel.representativeBadge = badge
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - Sections
    private var representativeBadgeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("나의 대표 배지")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    if let rep = viewModel.representativeBadge {
                        badgeIconView(badge: rep, size: 96, iconSize: 56)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(ColorSystem.labelNormalDisable)
                                .frame(width: 96, height: 96)
                        }
                    }
                    
                    Text(viewModel.representativeBadge?.title ?? "나의 대표 배지")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                    
                    Text(viewModel.representativeBadge == nil ? "아직 대표 배지가 없어요" : "나의 대표 배지입니다")
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                }
                Spacer()
            }
        }
    }
    private var activityBadgeSection: some View {
        VStack(alignment: .leading, spacing: 36) {
            sectionHeader(
                title: "활동 배지",
                count: viewModel.activityBadgeCountText
            )
            
            badgeGrid(items: viewModel.activityBadges, usePngBackground: false)
        }
    }
    
    private var challengeBadgeSection: some View {
        VStack(alignment: .leading, spacing: 36) {
            sectionHeader(
                title: "챌린지 배지",
                count: viewModel.challengeBadgeCountText
            )
            
            badgeGrid(items: viewModel.challengeBadges, usePngBackground: true)
        }
    }
    
    // MARK: - Components
    private func sectionHeader(title: String, count: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            Text(count)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.primaryStrong)
        }
    }
    
    private func badgeGrid(items: [BadgeItem], usePngBackground: Bool) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 40),
                GridItem(.flexible(), spacing: 40),
                GridItem(.flexible(), spacing: 40)
            ],
            spacing: 40
        ) {
            ForEach(items) { badge in
                badgeItemView(badge, usePngBackground: usePngBackground)
                    .onTapGesture {
                        selectedBadge = badge
                        isShowingDetail = true
                    }
            }
        }
    }
    
    private func badgeItemView(_ badge: BadgeItem, usePngBackground: Bool) -> some View {
        VStack(spacing: 8) {
            badgeIconView(badge: badge, size: 84, iconSize: 64)
            
            Text(badge.title)
                .fontStyle(.detail2Regular)
                .foregroundStyle(
                    badge.stage == .sprout
                    ? ColorSystem.labelNormalBasic
                    : ColorSystem.labelNormalNormal
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func badgeIconView(badge: BadgeItem, size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            badge.stage.backgroundView(size: size, cornerRadius: 24)
            
            Image(badge.stage == .sprout ? badge.iconOffName : badge.iconOnName, bundle: .designSystem)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Badge Detail View
private struct BadgeDetailView: View {
    let badge: BadgeItem
    let isRepresentative: Bool
    let onSetRepresentative: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var stageLabelText: String {
        badge.stage.displayName
    }
    
    private var descriptionText: String {
        badge.stage.description(badge.title)
    }
    
    private var buttonTitle: String {
        if badge.stage == .forest {
            return isRepresentative ? "대표 배지로 설정됨" : "대표 배지로 설정하기"
        } else {
            return "배지 획득하러 가기"
        }
    }
    
    private var isButtonEnabled: Bool {
        if badge.stage == .forest {
            return !isRepresentative
        } else {
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    HStack {
                        Text("배지 설명")
                            .fontStyle(.heading1Bold)
                            .foregroundStyle(ColorSystem.labelNormalStrong)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    ZStack {
                        badge.stage.backgroundView(size: 92, cornerRadius: 92)
                        
                        Image(badge.stage == .sprout ? badge.iconOffName : badge.iconOnName, bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                    }
                    
                    VStack(spacing: 6) {
                        
                        Text(stageLabelText)
                            .fontStyle(.detail1Medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ColorSystem.primaryAlternative)
                            )
                            .foregroundStyle(ColorSystem.primaryStrong)
                        
                        Text(badge.title)
                            .fontStyle(.heading3Bold)
                            .foregroundStyle(ColorSystem.labelNormalNormal)
                    }
                    
                    Text(descriptionText)
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                NextStepButton(
                    title: buttonTitle,
                    isEnabled: isButtonEnabled,
                    onTap: {
                        if badge.stage == .forest {
                            onSetRepresentative()
                        }
                        dismiss()
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(ColorSystem.backgroundNormalNormal)
        }
    }
}

