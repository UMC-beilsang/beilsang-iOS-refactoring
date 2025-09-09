//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "StorageCore",
  targets: [
    .target(
      name: "StorageCore",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.StorageCore",
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .external(name: "Alamofire")
      ]
    )
  ]
)
