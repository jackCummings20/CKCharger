// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CKCharger",
    platforms: [
        .iOS(.init("15")),
        .macOS(.init("12")),
        .tvOS(.init("15")),
        .watchOS(.init("8")),
    ],
    products: [
        .library(name: "CKCharger", targets: ["CKCharger"]),
    ],
    dependencies: [
        .package(name: "CloudKitCodable", url: "https://github.com/jackCummings20/CloudKitCodable", from: "1.0.0")
    ],
    targets: [
        .target(name: "CKCharger", dependencies: ["CloudKitCodable"]),
        .testTarget(name: "CKChargerTests", dependencies: ["CKCharger"]),
    ]
)
