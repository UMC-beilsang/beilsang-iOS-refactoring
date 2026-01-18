
// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Alamofire": .framework,
        "KakaoSDKCommon": .framework,
        "KakaoSDKAuth": .framework,
        "KakaoSDKUser": .framework,
    ],
    baseSettings: .settings(
        configurations: [
            .debug(name: "dev"),
            .debug(name: "stag"),
            .release(name: "prod")
        ]
    )
)
#endif

let package = Package(
    name: "beilsang-iOS",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.0")
    ]
)
