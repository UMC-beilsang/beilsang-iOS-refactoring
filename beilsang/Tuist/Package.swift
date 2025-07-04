
// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "SnapKit": .framework,
        "Alamofire": .framework
    ]
)
#endif

let package = Package(
    name: "beilsang-iOS",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.4"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0")
    ]
)
