// Projects/Shared/Navigation/Project.swift
import ProjectDescription

let project = Project(
  name: "NavigationShared",
  targets: [
    .target(
      name: "NavigationShared",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.beilsang.shared.navigation",
      deploymentTargets: .iOS("16.0"),
      infoPlist: .default,
      sources: ["Sources/**"]
    )
  ]
)
