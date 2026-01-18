import ProjectDescription

let project = Project(
    name: "NotificationDomain",
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
            name: "NotificationDomain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.beilsang.NotificationDomain",
            deploymentTargets: .iOS("18.5"),
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







