
// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "SnapKit": .framework,
        "Alamofire": .framework,
        "Kingfisher": .framework,
        "KakaoSDKCommon": .framework,
        "KakaoSDKAuth": .framework,
        "KakaoSDKUser": .framework,
        "SwiftyJSON": .framework
    ]
)
#endif

let package = Package(
    name: "beilsang-iOS",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.4"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.4.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2")
    ]
)
