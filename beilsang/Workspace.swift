//
//  Workspace.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let workspace = Workspace(
    name: "beilsang",
    projects: [
        "Projects/App",
        // Shared
        "Projects/Shared/Navigation",
        "Projects/Shared/UIComponents",
        "Projects/Shared/DesignSystem",
        "Projects/Shared/Models",
        "Projects/Shared/Utility",
        // Feature
        "Projects/Feature/Auth",
        "Projects/Feature/Challenge",
        "Projects/Feature/Discover",
        "Projects/Feature/MyPage",
        "Projects/Feature/Notification",
        // Domain
        "Projects/Domain/AuthDomain",
        "Projects/Domain/ChallengeDomain",
        // Core
        "Projects/Core/NetworkCore",
        "Projects/Core/StorageCore"
    ]
)
