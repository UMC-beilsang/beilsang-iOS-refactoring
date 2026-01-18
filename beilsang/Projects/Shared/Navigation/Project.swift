// Projects/Shared/Navigation/Project.swift
import ProjectDescription

let project = Project(
  name: "NavigationShared",
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
      name: "NavigationShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.shared.navigation",
      deploymentTargets: .iOS("18.5"),
      infoPlist: .default,
      sources: ["Sources/**"]
    )
  ]
)
