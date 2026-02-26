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

public struct ChallengeListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChallengeListViewModel
    @EnvironmentObject var coordinator: ChallengeCoordinator
    
    let category: Keyword
    
    public init(viewModel: ChallengeListViewModel, category: Keyword) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.category = category
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .tertiaryAdd(
                title: category.title,
                onBack: { dismiss() },
                onAdd: { coordinator.navigateToCreate() },
                onSearch: { coordinator.presentSearch() }
            ))
            
            // 필터 버튼 & 모집마감 체크박스
            HStack {
                // 좌측: 필터 버튼
                Button(action: {
                    viewModel.showFilterSheet = true
                }) {
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
                
                // 우측: 모집마감 체크박스
                Button(action: {
                    viewModel.toggleClosedChallenges()
                }) {
                    HStack(spacing: 6) {
                        Image(viewModel.hideClosedChallenges ? "checkIcon" : "noCheckIcon", bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        
                        Text("모집 마감")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        if viewModel.isLoading {
                            ChallengeListSkeletonView()
                                .transition(.opacity)
                        }
                        
                        if !viewModel.isLoading {
                            VStack(alignment: .leading, spacing: 0) {
                                bannerSection
                                    .padding(.top, 20)
                                    .padding(.bottom, 32)
                                
                                challengeListSection
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeOut(duration: 0.4), value: viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
            .refreshable {
                await viewModel.fetchChallenges(for: category, showSkeleton: true)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterBottomSheet(
                selectedFilter: viewModel.selectedFilter,
                onFilterSelected: { filter in
                    viewModel.applyFilter(filter)
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if !viewModel.items.isEmpty {
                viewModel.isLoading = false
            }
        }
        .task {
            if viewModel.items.isEmpty {
                await viewModel.fetchChallenges(for: category, showSkeleton: true)
            }
        }
    }
    
    private var bannerSection: some View {
        Button(action: {
            coordinator.navigateToCreate()
        }) {
            Image("listBannerIcon", bundle: .designSystem)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var challengeListSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.items) { item in
                ChallengeItemView(
                    title: item.title,
                    imageUrl: item.thumbnailImageUrl,
                    style: .progressList(
                        progress: item.progressText,
                        author: item.author ?? "익명"
                    ),
                    isRecruitmentClosed: item.isRecruitmentClosed
                ) {
                    coordinator.navigateToDetail(id: item.id)
                }
            }
        }
    }
}
