// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-mustache-cli",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .executable(name: "mustache", targets: ["swift-mustache-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.4.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0-beta"),
        .package(url: "https://github.com/jpsim/yams", from: "5.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "swift-mustache-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "Yams", package: "yams"),
            ]
        )
    ]
)
