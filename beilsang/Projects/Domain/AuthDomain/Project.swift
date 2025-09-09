import ProjectDescription

let project = Project(
    name: "AuthDomain",
    targets: [
        .target(
            name: "AuthDomain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.beilsang.AuthDomain",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "ModelsShared", path: "../../Shared/Models"),
                .project(target: "NetworkCore", path: "../../Core/NetworkCore"),
                .project(target: "StorageCore", path: "../../Core/StorageCore"),
                .external(name: "Alamofire")
            ]
        )
    ]
)
