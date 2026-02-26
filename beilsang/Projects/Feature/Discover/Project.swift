//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "DiscoverFeature",
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
      name: "DiscoverFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.DiscoverFeature",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "ChallengeDomain", path: "../../Domain/ChallengeDomain"),
        .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
        .project(target: "NavigationShared", path: "../../Shared/Navigation"),
      ]
    ),
    .target(
      name: "DiscoverFeatureUITests",
      destinations: .iOS,
      product: .uiTests,
      bundleId: "com.beilsang.DiscoverFeature.UITests",
      infoPlist: .default,
      sources: ["Feature/UITests/**"],
      dependencies: [
        .target(name: "DiscoverFeature")
      ],
      settings: .settings(
        base: ["SWIFT_VERSION": "5.9"],
        configurations: [
          .debug(name: "dev", xcconfig: "../../App/Config/dev.xcconfig"),
          .debug(name: "stag", xcconfig: "../../App/Config/stag.xcconfig"),
          .release(name: "prod", xcconfig: "../../App/Config/prod.xcconfig"),
        ]
      )
    ),
    .target(
      name: "DiscoverFeatureExample",
      destinations: .iOS,
      product: .app,
      bundleId: "com.beilsang.DiscoverFeatureExample.Example",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .file(path: "Example/Info.plist"),
      sources: ["Example/Sources/**"],
      resources: [],
      dependencies: [
        .target(name: "DiscoverFeature"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility")
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
        name: "DiscoverFeature",
        buildAction: .buildAction(targets: ["DiscoverFeature"]),
        testAction: .targets(["DiscoverFeatureUITests"], configuration: .configuration("dev"))
      ),
      .scheme(
        name: "DiscoverFeatureExample",
        buildAction: .buildAction(targets: ["DiscoverFeatureExample"]),
        runAction: .runAction(configuration: .configuration("dev"), executable: "DiscoverFeatureExample")
      )
  ]
)

