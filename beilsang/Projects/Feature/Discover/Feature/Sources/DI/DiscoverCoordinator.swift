//
//  DiscoverCoordinator.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/8/25.
//

import SwiftUI
import ModelsShared

@MainActor
public final class DiscoverCoordinator: ObservableObject {
    @Published public var path = NavigationPath()

    public init() {}

    public func navigateToChallengeList(category: Keyword) {
        path.append(DiscoverRoute.challengeList(category: category))
    }
    
    public func navigateToCreate(step: Int = 0) {
        path.append(DiscoverRoute.challengeCreate(step: step))
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path = NavigationPath()
    }
}

public enum DiscoverRoute: Hashable {
    case challengeList(category: Keyword)
    case challengeCreate(step: Int)
}

