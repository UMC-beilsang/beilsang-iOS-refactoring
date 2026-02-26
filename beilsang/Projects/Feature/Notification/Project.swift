//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "NotificationFeature",
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
      name: "NotificationFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.NotificationFeature",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
        .project(target: "StorageCore", path: "../../Core/StorageCore"),
        .project(target: "NotificationDomain", path: "../../Domain/NotificationDomain"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "NavigationShared", path: "../../Shared/Navigation"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
      ]
    ),
    .target(
      name: "NotificationFeatureExample",
      destinations: .iOS,
      product: .app,
      bundleId: "com.beilsang.NotificationFeatureExample.Example",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .file(path: "Example/Info.plist"),
      sources: ["Example/Sources/**"],
      resources: [],
      dependencies: [
        .target(name: "NotificationFeature"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "5.9"],
        configurations: [
          .debug(name: "dev", xcconfig: "../../App/Config/dev.xcconfig"),
          .debug(name: "stag", xcconfig: "../../App/Config/stag.xcconfig"),
          .release(name: "prod", xcconfig: "../../App/Config/prod.xcconfig"),
        ]
      )
    )
  ],
  schemes: [
    .scheme(
      name: "NotificationFeature",
      buildAction: .buildAction(targets: ["NotificationFeature"])
    ),
    .scheme(
      name: "NotificationFeatureExample",
      buildAction: .buildAction(targets: ["NotificationFeatureExample"]),
      runAction: .runAction(configuration: .configuration("dev"), executable: "NotificationFeatureExample")
    )
  ]
)
