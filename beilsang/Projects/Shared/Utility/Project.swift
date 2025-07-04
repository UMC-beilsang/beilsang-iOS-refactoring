//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "UtilityShared",
  targets: [
    .target(
      name: "UtilityShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.UtilityShared",
      infoPlist: .default,
      sources: ["Sources/**"]
    )
  ]
)
