//
//  AppRouter.swift
//  NavigationShared
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI

@MainActor
public final class AppRouter: ObservableObject {
    @Published public var selectedTab: Int = 0
    @Published public var showLogin: Bool = false
    @Published public var showSignup: Bool = false

    public init() {}

    public func switchTab(to index: Int) {
        selectedTab = index
    }

    public func presentLogin() {
        showLogin = true
    }

    public func presentSignup() {
        showSignup = true
    }
}
