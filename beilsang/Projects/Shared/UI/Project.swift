//
//  Project.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import ProjectDescription

let project = Project(
  name: "UIShared",
  targets: [
    .target(
      name: "UIShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.UIShared",
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: ["Resources/**"]
    )
  ]
)
