//
//  MyPageViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Combine
import SwiftUI
import UserDomain
import ModelsShared
import UtilityShared

@MainActor
public final class MyPageViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var userProfile: UserProfileData?
    @Published public var myFeeds: [FeedListItem] = []
    @Published public var isLoading: Bool = false
    @Published public var isFeedsLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var hasMoreFeeds: Bool = true
    @Published public var isInitialLoading: Bool = true
    
    // MARK: - Private Properties
    private let fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol
    private let fetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol
    private var currentFeedPage: Int = 0
    private let feedPageSize: Int = 4
    
    // MARK: - Init
    public init(
        fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol,
        fetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol
    ) {
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchMyFeedsUseCase = fetchMyFeedsUseCase
    }
    
    // MARK: - Public Methods
    public func loadUserProfile(showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }
        
        isLoading = true
        errorMessage = nil
        
        let shouldDelay = showSkeleton && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil
        
        do {
            userProfile = try await fetchUserProfileUseCase.execute()
            
            if let delay = delayTask {
                await delay.value
            }
        } catch {
            if let delay = delayTask {
                await delay.value
            }
            errorMessage = "프로필을 불러오는 데 실패했습니다."
            #if DEBUG
            print("❌ Failed to load user profile: \(error)")
            #endif
        }
        
        isLoading = false
        
        if showSkeleton {
            isInitialLoading = false
        }
    }
    
    public func loadMyFeeds(reset: Bool = false, showSkeleton: Bool = false) async {
        guard !isFeedsLoading else { return }
        
        if reset {
            currentFeedPage = 0
            myFeeds = []
            hasMoreFeeds = true
        }
        
        guard hasMoreFeeds else { return }
        
        if showSkeleton && reset {
            isInitialLoading = true
        }
        
        isFeedsLoading = true
        
        let shouldDelay = showSkeleton && reset && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil
        
        do {
            let response = try await fetchMyFeedsUseCase.execute(page: currentFeedPage, size: feedPageSize)
            
            if let delay = delayTask {
                await delay.value
            }
            
            myFeeds.append(contentsOf: response.content)
            hasMoreFeeds = response.hasNext
            currentFeedPage += 1
            
            #if DEBUG
            print("📷 Loaded \(response.content.count) feeds, total: \(myFeeds.count), hasMore: \(hasMoreFeeds)")
            #endif
        } catch {
            if let delay = delayTask {
                await delay.value
            }
            #if DEBUG
            print("❌ Failed to load my feeds: \(error)")
            #endif
        }
        
        isFeedsLoading = false
        
        if showSkeleton && reset {
            isInitialLoading = false
        }
    }
    
    // MARK: - Computed Properties
    public var nickname: String {
        userProfile?.nickname ?? "비밀상님"
    }
    
    public var profileImageUrl: String? {
        userProfile?.profileImage
    }
    
    public var totalPoint: String {
        guard let point = userProfile?.totalPoint else { return "0P" }
        return formatPoint(point)
    }
    
    /// 포인트 포맷팅 (큰 숫자 축약)
    private func formatPoint(_ value: Int) -> String {
        switch value {
        case 100_000_000...:  // 1억 이상
            let billions = Double(value) / 100_000_000
            return String(format: "%.0f억P", billions)
        case 10_000...:  // 1만 이상
            let tenThousands = Double(value) / 10_000
            return String(format: "%.0f만P", tenThousands)
        case 1_000...:  // 1천 이상
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return "\(formatter.string(from: NSNumber(value: value)) ?? "\(value)")P"
        default:
            return "\(value)P"
        }
    }
    
    public var feedCount: String {
        "\(userProfile?.countFeed ?? 0)개"
    }
    
    /// 성공한 챌린지 수
    public var successChallengeCount: String {
        "\(userProfile?.successChallenge ?? 0)개"
    }
    
    /// 실패한 챌린지 수
    public var failedChallengeCount: String {
        "\(userProfile?.failedChallenges ?? 0)개"
    }
    
    /// 진행중인 챌린지 수
    public var ongoingChallengeCount: String {
        "\(userProfile?.challenges ?? 0)개"
    }
    
    public var likesCount: String {
        "\(userProfile?.likes ?? 0)개"
    }
    
    /// 배지 수 (TODO: API에서 badges 필드 추가 시 연동)
    public var badgeCount: String {
        "0개"
    }
    
    // MARK: - Motto (Resolution)
    public var resolution: String? {
        userProfile?.resolution
    }
    
    /// Motto 모델로 변환 (아이콘 포함)
    public var motto: Motto? {
        guard let resolution = userProfile?.resolution, !resolution.isEmpty else { return nil }
        return Motto.allCases.first { $0.title == resolution }
    }
}

