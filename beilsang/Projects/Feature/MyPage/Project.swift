//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "MyPageFeature",
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
      name: "MyPageFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.MyPageFeature",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "UserDomain", path: "../../Domain/UserDomain"),
        .project(target: "ChallengeDomain", path: "../../Domain/ChallengeDomain"),
        .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
        .project(target: "StorageCore", path: "../../Core/StorageCore"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
        .project(target: "NavigationShared", path: "../../Shared/Navigation"),
        .external(name: "Alamofire")
      ]
    ),
    .target(
      name: "MyPageFeatureExample",
      destinations: .iOS,
      product: .app,
      bundleId: "com.beilsang.MyPageFeature.Example",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .file(path: "Example/Info.plist"),
      sources: ["Example/Sources/**"],
      resources: [],
      dependencies: [
        .target(name: "MyPageFeature"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility")
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "5.9"],
        configurations: [
          .debug(name: "dev"),
          .debug(name: "stag"),
          .release(name: "prod"),
        ]
      )
    )
  ],
  schemes: [
      .scheme(
        name: "MyPageFeatureExample",
        buildAction: .buildAction(targets: ["MyPageFeatureExample"]),
        runAction: .runAction(configuration: .configuration("dev"), executable: "MyPageFeatureExample")
      )
  ]
)
