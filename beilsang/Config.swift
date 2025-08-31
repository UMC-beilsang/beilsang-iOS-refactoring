//
//  Workspace.swift
//  beilsang
//
//  Created by Park Seyoung on 7/4/25.
//

import ProjectDescription

let config = Config(
  compatibleXcodeVersions: ["16.4"],
  swiftVersion: "5.9",
  generationOptions: .options(
    automaticSchemesOptions: .enabled(),
    disableSynthesizedResourceAccessors: false
  )
)
