import ProjectDescription

let project = Project(
    name: "ChallengeDomain",
    targets: [
        .target(
            name: "ChallengeDomain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.beilsang.ChallengeDomain",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "ModelsShared", path: "../../Shared/Models"),
                .project(target: "UtilityShared", path: "../../Shared/Utility"),
                .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
                .project(target: "StorageCore", path: "../../Core/StorageCore"),
                .external(name: "Alamofire")
            ]
        )
    ]
)
