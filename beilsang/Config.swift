//
//  Workspace.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let config = Config(
    compatibleXcodeVersions: [.upToNextMajor("26.0")],
    swiftVersion: "5.9",
    generationOptions: .options(
        disableSandbox: false,
        includeGenerateScheme: true
    )
)
