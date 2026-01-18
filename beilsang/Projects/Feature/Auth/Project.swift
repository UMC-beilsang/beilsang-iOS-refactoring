//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "AuthFeature",
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
      name: "AuthFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.AuthFeature",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "AuthDomain", path: "../../Domain/AuthDomain"),
        .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
        .project(target: "StorageCore", path: "../../Core/StorageCore"),
        .project(target: "NavigationShared", path: "../../Shared/Navigation"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
        .external(name: "KakaoSDKCommon"),
        .external(name: "KakaoSDKAuth"),
        .external(name: "KakaoSDKUser"),
        .external(name: "Alamofire")
      ]
    ),
    .target(
      name: "AuthFeatureExample",
      destinations: .iOS,
      product: .app,
      bundleId: "com.beilsang.AuthFeature.Example",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .file(path: "Example/Info.plist"),
      sources: ["Example/Sources/**"],
      resources: [],
      dependencies: [
        .target(name: "AuthFeature"),
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
        name: "AuthFeatureExample",
        buildAction: .buildAction(targets: ["AuthFeatureExample"]),
        runAction: .runAction(configuration: .configuration("dev"), executable: "AuthFeatureExample")
      )
  ]
)
