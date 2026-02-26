//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "UIComponentsShared",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ],
    configurations: [
      .debug(name: "dev"),
      .debug(name: "stag"),
      .release(name: "prod"),
    ]
  ),
  targets: [
    .target(
      name: "UIComponentsShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.UIComponentsShared",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "DesignSystemShared", path: "../DesignSystem")
      ]
    )
  ]
)
