//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "DesignSystemShared",
  targets: [
    .target(
      name: "DesignSystemShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.DesignSystemShared",
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: [
        .project(target: "ModelsShared", path: "../Models")
      ]
    )
  ]
)
