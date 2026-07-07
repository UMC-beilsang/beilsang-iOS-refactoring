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

public extension Foundation.Notification.Name {
    /// 프로필(이미지/닉네임 등) 수정이 완료되었을 때 발생
    static let profileDidUpdate = Foundation.Notification.Name("ProfileDidUpdate")
}

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
    /// 프로필 이미지 뷰를 강제로 다시 그리기 위한 토큰 (URL이 동일해도 캐시를 다시 읽도록)
    @Published public var profileImageReloadToken = UUID()
    
    // MARK: - Private Properties
    private let fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol
    private let fetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol
    private var currentFeedPage: Int = 0
    private let feedPageSize: Int = 4
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    public init(
        fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol,
        fetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol
    ) {
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchMyFeedsUseCase = fetchMyFeedsUseCase

        NotificationCenter.default.publisher(for: .profileDidUpdate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.profileImageReloadToken = UUID()
                Task { await self?.loadUserProfile() }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    public func loadInitialData(showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadUserProfile() }
            group.addTask { await self.loadMyFeeds(reset: true) }
        }

        if showSkeleton {
            isInitialLoading = false
        }
    }

    public func loadUserProfile(showSkeleton: Bool = false) async {
        guard !isLoading else { return }
        
        if showSkeleton {
            isInitialLoading = true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            userProfile = try await fetchUserProfileUseCase.execute()
        } catch {
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
            hasMoreFeeds = true
        }
        
        guard hasMoreFeeds else { return }
        
        if showSkeleton && reset {
            isInitialLoading = true
        }
        
        isFeedsLoading = true
        
        do {
            let response = try await fetchMyFeedsUseCase.execute(page: currentFeedPage, size: feedPageSize)
            
            if reset {
                myFeeds = []
            }
            myFeeds.append(contentsOf: response.content)
            hasMoreFeeds = response.hasNext
            currentFeedPage += 1
            
            #if DEBUG
            print("📷 Loaded \(response.content.count) feeds, total: \(myFeeds.count), hasMore: \(hasMoreFeeds)")
            #endif
        } catch {
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
        userProfile?.profileUrl
    }
    
    public var totalPoint: String {
        guard let point = userProfile?.totalPoint else { return "0P" }
        return formatPoint(point)
    }
    
    private func formatPoint(_ value: Int) -> String {
        switch value {
        case 100_000_000...:
            let billions = Double(value) / 100_000_000
            return String(format: "%.0f억P", billions)
        case 10_000...:
            let tenThousands = Double(value) / 10_000
            return String(format: "%.0f만P", tenThousands)
        case 1_000...:
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
    
    public var successChallengeCount: String {
        "\(userProfile?.successChallenge ?? 0)개"
    }
    
    public var failedChallengeCount: String {
        "\(userProfile?.failedChallenges ?? 0)개"
    }
    
    public var ongoingChallengeCount: String {
        "\(userProfile?.challenges ?? 0)개"
    }
    
    public var likesCount: String {
        "\(userProfile?.likes ?? 0)개"
    }
    
    public var badgeCount: String {
        "0개"
    }
    
    public var resolution: String? {
        userProfile?.resolution
    }
    
    public var motto: Motto? {
        guard let resolution = userProfile?.resolution, !resolution.isEmpty else { return nil }
        return Motto.allCases.first { $0.title == resolution }
    }
}
