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
    
    // 탭 상태
    @State private var selectedTab: Int = 0
    private let tabs = ["전체", "적립", "사용", "소멸"]
    
    public init(viewModel: PointViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            Header(type: .secondary(
                title: "포인트",
                onBack: { dismiss() }
            ))
            
            // 현재 포인트 섹션
            VStack(alignment: .leading, spacing: 20) {
                // "현재 포인트" 제목은 항상 표시
                Text("현재 포인트")
                    .fontStyle(.heading2Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                ZStack {
                    if viewModel.isInitialLoading {
                        // 포인트 값과 소멸 예정 포인트 카드만 스켈레톤
                        PointSkeletonView()
                            .transition(.opacity)
                    } else {
                        // 실제 포인트 값과 소멸 예정 포인트
                        VStack(alignment: .leading, spacing: 20) {
                            // 실제 포인트 값
                            Text("\(viewModel.formatNumber(viewModel.totalPoint))P")
                                .fontStyle(.title1Bold)
                                .foregroundStyle(ColorSystem.primaryHeavy)
                            
                            // 소멸 예정 포인트
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
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorSystem.labelNormalDisable)
                            )
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.4), value: viewModel.isInitialLoading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            // 탭 바 (항상 표시)
            tabBar
            
            // 포인트 내역 리스트
            ScrollView {
                ZStack {
                    if viewModel.isInitialLoading {
                        PointHistorySkeletonView()
                            .transition(.opacity)
                    } else {
                        LazyVStack(spacing: 0) {
                            let filteredPoints = viewModel.filteredPoints(by: selectedTab)
                            if filteredPoints.isEmpty {
                                emptyStateView
                            } else {
                                VStack(alignment: .center, spacing: 8) {
                                    ForEach(filteredPoints, id: \.id) { item in
                                        pointHistoryRow(item: item)
                                    }
                                }
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.4), value: viewModel.isInitialLoading)
                
                Spacer().frame(height: 100)
            }
            .padding(.top, 12)
        }
        .background(ColorSystem.backgroundNormalNormal)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 이미 데이터가 있으면 로딩 상태 즉시 해제 (깜빡임 방지)
            if !viewModel.points.isEmpty {
                viewModel.isInitialLoading = false
            }
        }
        .task {
            if viewModel.points.isEmpty {
                await viewModel.fetchPoints(showSkeleton: true)
            }
        }
        .refreshable {
            await viewModel.fetchPoints(showSkeleton: true)
        }
        .onChange(of: selectedTab) { _, _ in
            // 탭 변경 시 필터링만 (이미 로드된 데이터 사용)
        }
    }
    
    // MARK: - Point Header Section
    private var pointHeaderSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 현재 포인트
            Text("현재 포인트")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            Text("\(viewModel.formatNumber(viewModel.totalPoint))P")
                .fontStyle(.title1Bold)
                .foregroundStyle(ColorSystem.primaryHeavy)
            
            // 소멸 예정 포인트
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorSystem.labelNormalDisable)
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    // MARK: - Tab Bar
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
        .background(ColorSystem.backgroundNormalNormal)
    }
    
    // MARK: - Point History Row
    private func pointHistoryRow(item: PointItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // 날짜 + 타입
            Text("\(viewModel.formatDate(item.date)) \(item.status.displayName)")
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.labelNormalNormal)
            
            HStack {
                // 아이콘 + 설명
                HStack(spacing: 6) {
                    Image(item.status == .earn ? "pointIcon" : "pointNegativeIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text(item.name)
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorSystem.labelNormalDisable)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    private func pointText(for item: PointItem) -> String {
        if item.status == .earn {
            return "+\(viewModel.formatNumber(item.value))P"
        } else {
            return "-\(viewModel.formatNumber(abs(item.value)))P"
        }
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


