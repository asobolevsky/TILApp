// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "TILApp",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(
            name: "Vapor",
            url: "https://github.com/vapor/vapor.git",
            from: "3.0.0"
        ),
        .package(
            name: "FluentPostgreSQL",
            url: "https://github.com/vapor/fluent-postgresql.git",
            from: "1.0.0"
        ),
        .package(
            name: "Leaf",
            url: "https://github.com/vapor/leaf.git",
            from: "3.0.0"
        )
    ],
    targets: [
        .target(name: "App",
                dependencies: ["FluentPostgreSQL",
                               "Vapor",
                               "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
//            .product(name: "XCTVapor", package: "Vapor")
        ]),
    ]
)
