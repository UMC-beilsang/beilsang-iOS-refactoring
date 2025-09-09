//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "DiscoverFeature",
  targets: [
    .target(
      name: "DiscoverFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.DiscoverFeature",
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
        .external(name: "SnapKit")
      ]
    )
  ]
)
