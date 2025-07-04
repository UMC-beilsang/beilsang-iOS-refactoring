//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "SearchFeature",
  targets: [
    .target(
      name: "SearchFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.SearchFeature",
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "NetworkCore", path: "../../Core/Network"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "UIShared", path: "../../Shared/UI"),
        .external(name: "SnapKit")
      ]
    )
  ]
)
