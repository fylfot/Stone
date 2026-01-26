// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Stone",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Stone", targets: ["Stone"])
    ],
    targets: [
        .executableTarget(
            name: "Stone",
            path: ".",
            exclude: ["Package.swift", "Resources/Info.plist", "Tests"],
            resources: [
                .copy("Resources/Info.plist")
            ]
        ),
        .testTarget(
            name: "StoneTests",
            dependencies: ["Stone"],
            path: "Tests"
        )
    ]
)
