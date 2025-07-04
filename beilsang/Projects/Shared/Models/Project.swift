//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "ModelsShared",
  targets: [
    .target(
      name: "ModelsShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.ModelsShared",
      infoPlist: .default,
      sources: ["Sources/**"]
    )
  ]
)
