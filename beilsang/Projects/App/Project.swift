//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "App",
  settings: .settings(
    base: ["SWIFT_VERSION": "5.9"],
    configurations: [
      .debug(name: "dev", xcconfig: "Config/dev.xcconfig"),
      .debug(name: "stag", xcconfig: "Config/stag.xcconfig"),
      .release(name: "prod", xcconfig: "Config/prod.xcconfig"),
    ]
  ), targets: [
    .target(
        name: "App",
        destinations: .iOS,
        product: .app,
        bundleId: "com.beilsang.apps",
        infoPlist: .file(path: "Info.plist"),
        sources: ["Sources/**"],
        resources: ["Resources/**"],
        dependencies: [
            .project(target: "NavigationShared", path: "../Shared/Navigation"),
            .project(target: "DiscoverFeature", path: "../Feature/Discover"),
            .project(target: "AuthFeature", path: "../Feature/Auth"),
            .project(target: "NotificationFeature", path: "../Feature/Notification"),
            .project(target: "SearchFeature", path: "../Feature/Search"),
            .project(target: "MyPageFeature", path: "../Feature/MyPage"),
            .project(target: "LearnMoreFeature", path: "../Feature/LearnMore"),
            .project(target: "ChallengeFeature", path: "../Feature/Challenge")
        ]
    )
  ]
)
