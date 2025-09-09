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
        "Projects/Feature/**",
        "Projects/Core/**",
        "Projects/Shared/**",
        "Projects/Domain/**"
    ]
)
