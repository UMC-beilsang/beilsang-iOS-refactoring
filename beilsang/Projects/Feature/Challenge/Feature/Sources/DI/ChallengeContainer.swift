//
//  ChallengeContainer.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import Foundation

@MainActor
public final class ChallengeContainer {
    let homeViewModel: HomeViewModel
    
    public init() {
        self.homeViewModel = HomeViewModel()
    }
}
