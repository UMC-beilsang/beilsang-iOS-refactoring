//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "AuthFeature",
  targets: [
    .target(
      name: "AuthFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.AuthFeature",
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "NetworkCore", path: "../../Core/Network"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
        .external(name: "SnapKit"),
        .external(name: "KakaoSDKCommon"),
        .external(name: "KakaoSDKAuth"),
        .external(name: "KakaoSDKUser"),
        .external(name: "SwiftyJSON"),
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
          .debug(name: "dev", xcconfig: "../../App/Config/dev.xcconfig"),
          .debug(name: "stag", xcconfig: "../../App/Config/stag.xcconfig"),
          .release(name: "prod", xcconfig: "../../App/Config/prod.xcconfig"),
        ]
      )
    )
  ]
)
