//
//  Project.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let project = Project(
  name: "ChallengeFeature",
  targets: [
    .target(
      name: "ChallengeFeature",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.ChallengeFeature",
      infoPlist: .default,
      sources: ["Feature/Sources/**"],
      dependencies: [
        .project(target: "ChallengeDomain", path: "../../Domain/ChallengeDomain"),
        .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
        .project(target: "ModelsShared", path: "../../Shared/Models"),
        .project(target: "UtilityShared", path: "../../Shared/Utility"),
        .project(target: "DesignSystemShared", path: "../../Shared/DesignSystem"),
        .project(target: "UIComponentsShared", path: "../../Shared/UIComponents"),
        .external(name: "SnapKit")
      ]
    ),
    
    // 단위 테스트 타겟 추가
    .target(
      name: "ChallengeFeatureTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "com.beilsang.ChallengeFeature.Tests",
      infoPlist: .default,
      sources: ["Feature/Tests/**"],
      dependencies: [
        .target(name: "ChallengeFeature"),
        .project(target: "ChallengeDomain", path: "../../Domain/ChallengeDomain"),
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
    ),
    
    // UI 테스트 타겟 추가 (선택사항)
    .target(
      name: "ChallengeFeatureUITests",
      destinations: .iOS,
      product: .uiTests,
      bundleId: "com.beilsang.ChallengeFeature.UITests",
      infoPlist: .default,
      sources: ["Feature/UITests/**"],
      dependencies: [
        .target(name: "ChallengeFeature")
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
      name: "ChallengeFeatureExample",
      destinations: .iOS,
      product: .app,
      bundleId: "com.beilsang.ChallengeFeatureExample.Example",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .file(path: "Example/Info.plist"),
      sources: ["Example/Sources/**"],
      resources: [],
      dependencies: [
        .target(name: "ChallengeFeature"),
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
        name: "ChallengeFeature",
        buildAction: .buildAction(targets: ["ChallengeFeature"]),
        testAction: .targets(["ChallengeFeatureTests"])
      ),
      .scheme(
        name: "ChallengeFeatureTests",
        buildAction: .buildAction(targets: ["ChallengeFeature", "ChallengeFeatureTests"]),
        testAction: .targets(["ChallengeFeatureTests"])
      ),
      .scheme(
        name: "ChallengeFeatureExample",
        buildAction: .buildAction(targets: ["ChallengeFeatureExample"]),
        runAction: .runAction(executable: "ChallengeFeatureExample")
      )
  ]
)
