//
//  MyFeedListViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import Foundation
import UserDomain
import ModelsShared

@MainActor
public final class MyFeedListViewModel: ObservableObject {
    @Published public var feeds: [FeedListItem] = []
    @Published public var isLoading: Bool = true
    @Published public var errorMessage: String?
    @Published public var hasNext: Bool = true
    @Published public var isInitialLoading: Bool = true
    
    private let fetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    
    public init(fetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol) {
        self.fetchMyFeedsUseCase = fetchMyFeedsUseCase
    }
    
    public func fetchFeeds(
        tabIndex: Int,
        category: Keyword,
        reset: Bool = false,
        showSkeleton: Bool = false
    ) async {
        if reset {
            currentPage = 0
            feeds = []
            hasNext = true
        }
        
        guard hasNext else { return }
        
        if showSkeleton && reset {
            isInitialLoading = true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await fetchMyFeedsUseCase.execute(page: currentPage, size: pageSize)
            
            feeds.append(contentsOf: response.content)
            currentPage += 1
            hasNext = response.hasNext
            
            #if DEBUG
            print("📷 Fetched \(response.content.count) feeds for tab: \(tabIndex), category: \(category.rawValue)")
            #endif
        } catch {
            errorMessage = "피드 목록을 불러오는 데 실패했습니다."
            #if DEBUG
            print("❌ Error fetching feeds: \(error)")
            #endif
        }
        
        isLoading = false
        
        if showSkeleton && reset {
            isInitialLoading = false
        }
    }
}
