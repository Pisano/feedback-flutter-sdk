// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "feedback_flutter_sdk",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "feedback-flutter-sdk", targets: ["feedback_flutter_sdk"])
    ],
    dependencies: [
        // Mirrors the `s.dependency 'Pisano', '~> 1.0.21'` constraint of the podspec.
        .package(url: "https://github.com/Pisano/pisano-ios.git", .upToNextMinor(from: "1.0.21"))
    ],
    targets: [
        .target(
            name: "feedback_flutter_sdk",
            dependencies: [
                .product(name: "PisanoFeedback", package: "pisano-ios")
            ]
        )
    ]
)
