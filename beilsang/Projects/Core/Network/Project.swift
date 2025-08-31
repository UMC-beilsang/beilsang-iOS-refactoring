//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "NetworkCore",
  targets: [
    .target(
      name: "NetworkCore",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.NetworkCore",
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .external(name: "Alamofire")
      ]
    )
  ]
)
