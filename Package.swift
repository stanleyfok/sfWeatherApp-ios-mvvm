// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sfWeatherApp-iOS-mvvm",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "sfWeatherApp-iOS-mvvm",
            targets: ["sfWeatherApp-iOS-mvvm"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "sfWeatherApp-iOS-mvvm",
            dependencies: []),
        .testTarget(
            name: "sfWeatherApp-iOS-mvvmTests",
            dependencies: ["sfWeatherApp-iOS-mvvm"]),
    ]
)
