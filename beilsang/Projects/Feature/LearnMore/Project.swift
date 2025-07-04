//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "LearnMoreFeature",
  targets: [
    .target(
      name: "LearnMoreFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.LearnMoreFeature",
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "NetworkCore", path: "../../Core/Network"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .external(name: "SnapKit")
      ]
    )
  ]
)
