//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "App",
  targets: [
    .target(
      name: "App",
      destinations: .iOS,
      product: .app,
      bundleId: "com.beilsang.apps",
      infoPlist: .file(path: "Info.plist"),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "HomeFeature", path: "../Feature/Home"),
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
