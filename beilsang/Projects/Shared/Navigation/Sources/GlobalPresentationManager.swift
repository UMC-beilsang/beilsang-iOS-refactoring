//
//  GlobalPresentationManager.swift
//  NavigationShared
//
//  Created by Seyoung Park on 10/31/25.
//

import SwiftUI

@MainActor
public final class GlobalPresentationManager: ObservableObject {
    // MARK: - Presentation Types
    public struct FeedPresentation: Identifiable {
        public let id: Int
    }

    public struct ChallengePresentation: Identifiable {
        public let id: Int
    }

    public struct ProfilePresentation: Identifiable {
        public let id: String
    }
    
    public struct MyChallengeListPresentation: Identifiable {
        public let id = UUID()
        public let tabIndex: Int  // 0: 참여, 1: 달성, 2: 실패
    }
    
    public struct MyFeedListPresentation: Identifiable {
        public let id = UUID()
    }
    
    public struct FavoriteChallengeListPresentation: Identifiable {
        public let id = UUID()
    }
    
    public struct SearchPresentation: Identifiable {
        public let id = UUID()
    }
    
    public struct ChallengeAddPresentation: Identifiable {
        public let id = UUID()
    }

    // MARK: - Published Properties
    @Published public var presentedFeed: FeedPresentation? = nil
    @Published public var presentedChallenge: ChallengePresentation? = nil
    @Published public var presentedProfile: ProfilePresentation? = nil
    @Published public var presentedMyChallengeList: MyChallengeListPresentation? = nil
    @Published public var presentedMyFeedList: MyFeedListPresentation? = nil
    @Published public var presentedFavoriteChallengeList: FavoriteChallengeListPresentation? = nil
    @Published public var presentedSearch: SearchPresentation? = nil
    @Published public var presentedChallengeAdd: ChallengeAddPresentation? = nil

    public init() {}

    // MARK: - Present Methods
    public func presentFeed(id: Int) {
        presentedFeed = FeedPresentation(id: id)
    }

    public func presentChallenge(id: Int) {
        presentedChallenge = ChallengePresentation(id: id)
    }

    public func presentProfile(id: String) {
        presentedProfile = ProfilePresentation(id: id)
    }
    
    public func presentMyChallengeList(tabIndex: Int = 0) {
        presentedMyChallengeList = MyChallengeListPresentation(tabIndex: tabIndex)
    }
    
    public func presentMyFeedList() {
        presentedMyFeedList = MyFeedListPresentation()
    }
    
    public func presentFavoriteChallengeList() {
        presentedFavoriteChallengeList = FavoriteChallengeListPresentation()
    }
    
    public func presentSearch() {
        presentedSearch = SearchPresentation()
    }
    
    public func presentChallengeAdd() {
        presentedChallengeAdd = ChallengeAddPresentation()
    }

    public func dismissAll() {
        presentedFeed = nil
        presentedChallenge = nil
        presentedProfile = nil
        presentedMyChallengeList = nil
        presentedMyFeedList = nil
        presentedFavoriteChallengeList = nil
        presentedSearch = nil
        presentedChallengeAdd = nil
    }
}
