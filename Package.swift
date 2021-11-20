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
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "SwiftPuLP",
            dependencies: [.product(name: "PythonKit", package: "PythonKit"),
                           .product(name: "Collections", package: "swift-collections"),
                          ]),
        .testTarget(
            name: "SwiftPuLPTests",
            dependencies: ["SwiftPuLP",
                           .product(name: "Algorithms", package: "swift-algorithms")]),
    ]
)
