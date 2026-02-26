//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by Seyoung Park on 10/7/25.
//

import Foundation
import SwiftUI

@MainActor
public final class AuthCoordinator: ObservableObject {
    @Published public var path = NavigationPath()
    
    public init() {}
    
    // MARK: - Navigation
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path = NavigationPath()
    }
}

