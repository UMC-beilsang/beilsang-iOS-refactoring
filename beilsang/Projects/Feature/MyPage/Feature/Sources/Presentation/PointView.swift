//
//  PointView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared

public struct PointView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: PointViewModel

    @State private var selectedTab: Int = 0
    private let tabs = ["전체", "적립", "사용", "소멸"]

    public init(viewModel: PointViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .secondary(
                title: "포인트",
                onBack: { dismiss() }
            ))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    // 포인트 요약: 스크롤과 함께 올라감
                    pointSummarySection

                    // 탭 + 내역: 탭 바는 스크롤 시 상단에 고정
                    Section {
                        pointHistorySection
                            .padding(.top, 12)
                            .padding(.bottom, 100)
                    } header: {
                        tabBar
                            .background(ColorSystem.backgroundNormalNormal)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(ColorSystem.backgroundNormalNormal)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !viewModel.point.isEmpty {
                viewModel.isInitialLoading = false
            }
        }
        .task {
            if viewModel.point.isEmpty {
                await viewModel.fetchPoints(showSkeleton: true)
            }
        }
        .refreshable {
            await viewModel.fetchPoints(showSkeleton: false)
        }
    }

    // MARK: - Point Summary

    private var pointSummarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("현재 포인트")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)

            ZStack {
                if viewModel.isInitialLoading {
                    PointSkeletonView()
                        .transition(.opacity)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(viewModel.formatNumber(viewModel.totalPoint))P")
                            .fontStyle(.title1Bold)
                            .foregroundStyle(ColorSystem.primaryHeavy)

                        HStack {
                            HStack(spacing: 4) {
                                Image("warningIconRed", bundle: .designSystem)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("소멸 예정 포인트")
                                    .fontStyle(.body2SemiBold)
                                    .foregroundStyle(ColorSystem.labelNormalNormal)
                            }
                            Spacer()
                            Text("-\(viewModel.formatNumber(viewModel.expiringPoints))P")
                                .fontStyle(.body2SemiBold)
                                .foregroundStyle(ColorSystem.semanticNegativeHeavy)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 12).fill(ColorSystem.labelNormalDisable))
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.isInitialLoading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 12)
    }

    // MARK: - Tab Bar (sticky)

    private var tabBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(ColorSystem.lineNormal)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    } label: {
                        VStack(spacing: 16) {
                            Text(tabs[index])
                                .fontStyle(selectedTab == index ? .heading3Bold : .heading3SemiBold)
                                .foregroundStyle(selectedTab == index ? ColorSystem.primaryHeavy : ColorSystem.labelNormalBasic)
                            Rectangle()
                                .fill(selectedTab == index ? ColorSystem.primaryStrong : Color.clear)
                                .frame(height: 2)
                        }
                        .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 12)
    }

    // MARK: - Point History

    @ViewBuilder
    private var pointHistorySection: some View {
        if viewModel.isInitialLoading {
            PointHistorySkeletonView()
                .transition(.opacity)
        } else {
            let filtered = viewModel.filteredPoints(by: selectedTab)
            if filtered.isEmpty {
                emptyStateView
            } else {
                VStack(alignment: .center, spacing: 8) {
                    ForEach(filtered, id: \.id) { item in
                        pointHistoryRow(item: item)
                    }
                }
            }
        }
    }

    // MARK: - Point History Row

    private func pointHistoryRow(item: PointItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(viewModel.formatDate(item.date)) \(item.status.displayName)")
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.labelNormalNormal)

            HStack {
                HStack(spacing: 6) {
                    Image(item.status == .earn ? "pointIcon" : "pointNegativeIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(item.name ?? "")
                        .fontStyle(.body1Bold)
                        .foregroundStyle(ColorSystem.labelNormalStrong)
                }
                Spacer()
                Text(pointText(for: item))
                    .fontStyle(.body1Bold)
                    .foregroundStyle(item.status == .earn ? ColorSystem.primaryHeavy : ColorSystem.semanticNegativeHeavy)
            }

            HStack(alignment: .center) {
                Spacer()
                if let expiryDate = viewModel.formatExpiryDate(item.date, period: item.period) {
                    Text("\(expiryDate) 소멸 예정")
                        .fontStyle(.detail2Regular)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 12).fill(ColorSystem.labelNormalDisable))
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private func pointText(for item: PointItem) -> String {
        item.status == .earn
            ? "+\(viewModel.formatNumber(item.value))P"
            : "-\(viewModel.formatNumber(abs(item.value)))P"
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("포인트 내역이 없어요")
                .fontStyle(.body1SemiBold)
                .foregroundStyle(ColorSystem.labelNormalNormal)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
    }
}
