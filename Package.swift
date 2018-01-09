// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCodables",
    products: [
        .library(
            name: "SwiftCodables",
            targets: ["SwiftCodables"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftCodables",
			dependencies: []),
        .testTarget(
            name: "SwiftCodablesTests",
            dependencies: ["SwiftCodables"]),
    ]
)
