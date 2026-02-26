//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "UtilityShared",
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
      name: "UtilityShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.UtilityShared",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Sources/**"]
    )
  ]
)
