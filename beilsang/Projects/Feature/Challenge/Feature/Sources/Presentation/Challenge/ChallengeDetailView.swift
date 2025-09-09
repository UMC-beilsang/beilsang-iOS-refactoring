//
//  ChallengeDetailView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain

struct ChallengeDetailView: View {
    @StateObject private var viewModel: ChallengeDetailViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    
    init(viewModel: ChallengeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Header(type: .tertiary(title: "챌린지", onBack:  { dismiss() }, onOption: {}))
                    
                    ChallengeImageView(
                        imageURL: viewModel.imageURL,
                        participantText: viewModel.participantText
                    )
                    
                    // Section 1
                    challengeDetailSection1
                    
                    sectionDivider
                    
                    // Section 2
                    challengeDetailSection2
                    
                    sectionDivider
                    
                    // Section 3
                    challengeDetailSection3

                    Spacer()
                        .frame(minHeight: UIScreen.main.bounds.height * 0.21)
                }
            }
            
            ChallengeBottomButton(
                state: viewModel.state,
                isLiked: viewModel.isLiked,
                likeCount: viewModel.likeCount,
                onLikeTap: {},
                onMainAction: {}
            )
        }
        .task {
            await viewModel.loadRecommendedChallenges()
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var challengeDetailSection1: some View {
        VStack(alignment: .leading, spacing: 0) {
            ChallengeTitleView(
                title: viewModel.title,
                createdAtText: viewModel.createdAtText
            )
            
            CategorySmallButton(keyword: Keyword(rawValue: viewModel.category) ?? .bicycle, action: {})
            
            ChallengeInfoView(
                state: viewModel.state,
                dDayText: viewModel.dDayText,
                startDateText: viewModel.startDateText,
                depositText: viewModel.depositText
            )
        }
        .padding(.horizontal, 24)
    }
    
    private var challengeDetailSection2: some View {
        Group {
            switch viewModel.state {
            case .enrolled:
                // 참여 - 갤러리
                ChallengeFeedView(onSeeAllTap: {
                    // TODO: - 전체보기 액션
                })
            case .notEnrolled:
                // 미참여 - 세부설명, 유의사항, 보상포인트
                VStack(spacing: 0) {
                    ChallengeDescriptionView(description: viewModel.description)
                    ChallengeCertView(certImages: viewModel.certImages)
                    ChallengeDepositInfoView()
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var challengeDetailSection3: some View {
        Group {
            switch viewModel.state {
            case .enrolled:
                // 참여 - 세부설명, 보상포인트
                VStack(spacing: 0) {
                    ChallengeDescriptionView(description: viewModel.description)
                    ChallengeDepositInfoView()
                }
            case .notEnrolled:
                // 미참여 - 추천 챌린지
                ChallengeRecommendView(recommendChallenges: viewModel.recommendChallenges)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var sectionDivider: some View {
        Rectangle()
            .fill(ColorSystem.labelNormalDisable)
            .frame(height: 8)
            .padding(.top, 24)
    }
}

struct ChallengeDetailView_Preview: PreviewProvider {
    static var previews: some View {
        FontRegister.registerFonts()
        
        let mockChallenge = Challenge(
            id: "1",
            title: "플로깅",
            description: """
            일주일에 한 번씩 길을 걸으며 플로깅을 해보는 건 어떨까요?
            '우리 가치 플로깅하자'는 챌린저 분들이 함께 활동을 인증하며 플로깅 문화를 확장시키는 챌린지입니다! 여러분의 많은 참여 기대하겠습니다!
            """,
            category: "plogging",
            status: "IN_PROGRESS",
            progress: 30.0,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            currentParticipants: 30,
            maxParticipants: 100,
            depositAmount: 1000,
            certificationMethod: "사진 인증",
            infoImageUrls: ["challengeThumbnail1"],
            certImageUrls: ["challengeThumbnail1", "challengeThumbnail2", "challengeThumbnail1"],
            thumbnailImageUrl: "challengeThumbnail1",
            isLiked: false,
            likeCount: 5,
            isParticipating: false,
            createdAt: Date()
        )
        
        let mockRepository = MockChallengeRepository()
        
        return ChallengeDetailView(
            viewModel: ChallengeDetailViewModel(challenge: mockChallenge, repository: mockRepository)
        )
        .previewLayout(.sizeThatFits)
    }
}
