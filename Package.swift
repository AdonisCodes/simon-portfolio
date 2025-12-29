// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "portfolio",
    dependencies: [
        .package(url: "https://github.com/GetAutomaApp/SwiftVan", branch: "main"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", from: "0.36.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "portfolio",
            dependencies: [
                .product(name: "SwiftVan", package: "SwiftVan"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
            ]
        )
    ]
)
