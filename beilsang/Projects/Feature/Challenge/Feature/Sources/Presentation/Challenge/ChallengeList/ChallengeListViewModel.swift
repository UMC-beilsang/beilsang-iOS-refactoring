//
//  ChallengeListViewModel.swift
//  ChallengeFeature
//  Created by Seyoung Park on 9/3/25.
//

import Foundation
import ChallengeDomain
import ModelsShared

@MainActor
public final class ChallengeListViewModel: ObservableObject {
    @Published public var items: [ChallengeItemViewModel] = []
    @Published public var isLoading: Bool = true
    @Published public var selectedFilter: ChallengeFilter = .recent
    @Published public var showFilterSheet: Bool = false
    @Published public var hideClosedChallenges: Bool = false
    
    private var allItems: [ChallengeItemViewModel] = []
    
    private let fetchChallengeListUseCase: FetchChallengeListUseCaseProtocol
    
    public init(fetchChallengeListUseCase: FetchChallengeListUseCaseProtocol) {
        self.fetchChallengeListUseCase = fetchChallengeListUseCase
    }
    
    // 필터 적용 후 서버에서 재조회
    public func applyFilter(_ filter: ChallengeFilter, category: Keyword) async {
        selectedFilter = filter
        showFilterSheet = false
        await fetchChallenges(for: category, showSkeleton: true)
    }
    
    // 모집마감 체크박스 토글
    public func toggleClosedChallenges(category: Keyword) {
        hideClosedChallenges.toggle()
        Task {
            await fetchChallenges(for: category, showSkeleton: true)
        }
    }
    
    public func fetchChallenges(for category: Keyword, showSkeleton: Bool = false) async {
        isLoading = true
        
        let currentFilter = self.selectedFilter
        let showClosedOnly = self.hideClosedChallenges
        
        // ✅ 1. 서버에 전달할 정렬 타입만 결정
        let sortType = currentFilter == .recent ? "DEADLINE_SOON" : "NEWEST"
        let categoryParam = category == .all ? nil : category.apiCategory
        let closedCategoryParam = category.apiCategory
        
        async let fetchTask = Task {
            do {
                if showClosedOnly {
                    // ✅ 2. 모집마감 챌린지만 (3.3 API) — closed API에서 왔으므로 isClosed = true
                    let closedRequest = ClosedChallengeListRequest(
                        category: closedCategoryParam,
                        page: 0,
                        size: 20
                    )
                    let closedResponse = try await fetchChallengeListUseCase.executeClosed(request: closedRequest)
                
                    return closedResponse.content.map { ChallengeItemViewModel(challengeItem: $0, isClosed: true) }
                    
                } else {
                    // ✅ 3. 모집중 챌린지만 (3.2 API) — open API에서 왔으므로 isClosed = false
                    let openRequest = OpenChallengeListRequest(
                        category: categoryParam,
                        sortType: sortType,
                        page: 0,
                        size: 20
                    )
                    let openResponse = try await fetchChallengeListUseCase.executeOpen(request: openRequest)
                    
                    return openResponse.content.map { ChallengeItemViewModel(challengeItem: $0, isClosed: false) }
                }
            } catch {
                print("❌ Error fetching challenges: \(error)")
                return []
            }
        }
        
        do {
            let items = try await fetchTask.value
            self.allItems = items
            self.items = items
        } catch {
            self.allItems = []
            self.items = []
        }
        
        isLoading = false
    }
}
