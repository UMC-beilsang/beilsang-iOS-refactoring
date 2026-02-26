import ProjectDescription

let project = Project(
    name: "App",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "5.9"
        ],
        configurations: [
            .debug(name: "dev", xcconfig: "Config/dev.xcconfig"),
            .debug(name: "stag", xcconfig: "Config/stag.xcconfig"),
            .release(name: "prod", xcconfig: "Config/prod.xcconfig"),
        ]
    ),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.beilsang.apps",
            deploymentTargets: .iOS("18.5"),
            infoPlist: .file(path: "Info.plist"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "NavigationShared", path: "../Shared/Navigation"),
                .project(target: "UIComponentsShared", path: "../Shared/UIComponents"),
                .project(target: "DesignSystemShared", path: "../Shared/DesignSystem"),
                .project(target: "ModelsShared", path: "../Shared/Models"),
                .project(target: "UtilityShared", path: "../Shared/Utility"),
                .project(target: "AuthFeature", path: "../Feature/Auth"),
                .project(target: "ChallengeFeature", path: "../Feature/Challenge"),
                .project(target: "DiscoverFeature", path: "../Feature/Discover"),
                .project(target: "MyPageFeature", path: "../Feature/MyPage"),
                .project(target: "NotificationFeature", path: "../Feature/Notification"),
                .project(target: "ChallengeDomain", path: "../Domain/ChallengeDomain"),
                .project(target: "AuthDomain", path: "../Domain/AuthDomain"),
                .project(target: "NotificationDomain", path: "../Domain/NotificationDomain"),
                .project(target: "NetworkCore", path: "../Core/NetworkCore"),
                .project(target: "StorageCore", path: "../Core/StorageCore"),
                .external(name: "Alamofire")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "App-dev",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            testAction: .targets([], configuration: "dev"),
            runAction: .runAction(configuration: "dev"),
            archiveAction: .archiveAction(configuration: "dev")
        ),
        .scheme(
            name: "App-stag",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            testAction: .targets([], configuration: "stag"),
            runAction: .runAction(configuration: "stag"),
            archiveAction: .archiveAction(configuration: "stag")
        ),
        .scheme(
            name: "App-prod",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            testAction: .targets([], configuration: "prod"),
            runAction: .runAction(configuration: "prod"),
            archiveAction: .archiveAction(configuration: "prod")
        ),
    ]
)
