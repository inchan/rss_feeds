// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RssFeed",
    platforms: [
        .macOS(.v12)  // macOS 12 이상 지원
    ],
    products: [
        .executable(name: "RssFeed", targets: ["RssFeed"])
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.6")
    ],
    targets: [
        .executableTarget(
            name: "RssFeed",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup")
            ]
        )
    ]
)
