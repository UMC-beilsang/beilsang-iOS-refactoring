//
//  ChallengeRouter.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import ModelsShared

@MainActor
public final class ChallengeRouter: ObservableObject {
    @Published public var path: [ChallengeRoute] = []

    public init() {}

    public func navigateToChallengeList(category: Keyword) {
        path.append(.challengeList(category: category))
    }

    public func navigateToDetail(id: String) {
        path.append(.challengeDetail(id: id))
    }
    
    public func navigateToCreate(step: Int = 0) {
        path.append(.challengeCreate(step: step))
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path.removeAll()
    }
}

public enum ChallengeRoute: Hashable {
    case challengeList(category: Keyword)
    case challengeDetail(id: String)
    case challengeCreate(step: Int)
}
