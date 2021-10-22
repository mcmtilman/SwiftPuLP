// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPuLP",
    products: [
        .library(
            name: "SwiftPuLP",
            targets: ["SwiftPuLP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "SwiftPuLP",
            dependencies: ["PythonKit"]),
        .testTarget(
            name: "SwiftPuLPTests",
            dependencies: ["SwiftPuLP"]),
    ]
)
