//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "UIComponentsShared",
  targets: [
    .target(
      name: "UIComponentsShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.UIComponentsShared",
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "DesignSystemShared", path: "../DesignSystem")
      ]
    )
  ]
)
