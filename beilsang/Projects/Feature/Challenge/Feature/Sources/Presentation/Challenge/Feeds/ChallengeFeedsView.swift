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

struct ChallengeFeedsView: View {
    @StateObject private var viewModel: ChallengeFeedsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(challengeId: Int, repository: ChallengeRepositoryProtocol) {
        self._viewModel = StateObject(
            wrappedValue: ChallengeFeedsViewModel(
                challengeId: challengeId,
                repository: repository
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .tertiaryReport(title: "인증 갤러리",
                                         onBack: { dismiss() }, onOption: {}
                                        ))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing : 0) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14)
                    ], spacing: 14) {
                        ForEach(viewModel.thumbnails.indices, id: \.self) { index in
                            let thumbnail = viewModel.thumbnails[index]
                            
                            AsyncImage(url: URL(string: thumbnail.feedUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(1.3, contentMode: .fill)
                                    .cornerRadius(20)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1.3, contentMode: .fill)
                                    .cornerRadius(20)
                            }
                            .clipped()
                            .overlay(alignment: .topTrailing) {
                                if thumbnail.isMyFeed {
                                    Text("내 사진")
                                        .fontStyle(.detail1Medium)
                                        .foregroundColor(ColorSystem.labelWhite)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(ColorSystem.primaryStrong)
                                        .cornerRadius(4)
                                        .padding(12)
                                }
                            }
                            .onTapGesture {
                                viewModel.showFeedDetail(feedId: thumbnail.id)
                            }
                            .onAppear {
                                // 마지막에서 2번째 아이템이 보이면 다음 페이지 로드
                                if index == viewModel.thumbnails.count - 2 {
                                    Task {
                                        await viewModel.loadMoreFeeds()
                                    }
                                }
                            }
                        }
                    }
                    
                    // 로딩 인디케이터
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
                .padding(.top, 30)
                .padding(.horizontal, 24)
            }
        }
        .task {
            await viewModel.loadFeeds()
        }
        .fullScreenCover(isPresented: $viewModel.showFeedDetail) {
            if let feedId = viewModel.selectedFeedId {
                ChallengeFeedDetailView(
                    feedId: feedId,
                    repository: viewModel.repository
                )
            }
        }
    }
}

#Preview {
    let _ = FontRegister.registerFonts()
    
    let mockRepository = MockChallengeRepository()
    
    return ChallengeFeedsView(
        challengeId: 1,
        repository: mockRepository
    )
    .environmentObject(ToastManager())
}
