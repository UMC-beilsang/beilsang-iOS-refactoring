//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "NetworkCore",
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
      name: "NetworkCore",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.NetworkCore",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "StorageCore", path: "../StorageCore"),
        .external(name: "Alamofire")
      ]
    )
  ]
)
