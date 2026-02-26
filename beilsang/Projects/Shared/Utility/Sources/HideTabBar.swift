//
//  HideTabBar.swift
//  UtilityShared
//
//  Created by Seyoung Park on 10/31/25.
//

import Foundation
// MARK: - View+HideTabBar.swift
import SwiftUI

extension View {
    public func hideTabBar(_ shouldHide: Bool) -> some View {
        self
            .toolbar(shouldHide ? .hidden : .visible, for: .tabBar)
    }
}
