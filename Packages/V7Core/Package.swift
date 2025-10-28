// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "V7Core",
    platforms: [
        .iOS(.v18),      // iOS-only target for iPhone performance optimization
        .macOS(.v15)     // macOS 15.0 required for testing and development
    ],
    products: [
        // V7Core is the foundation package with ZERO external dependencies
        .library(
            name: "V7Core",
            targets: ["V7Core"]
        ),
    ],
    dependencies: [
        // ZERO external dependencies - this is the foundation layer
    ],
    targets: [
        // V7Core contains Sacred UI Constants, base models, and shared utilities
        .target(
            name: "V7Core",
            dependencies: [],
            resources: [
                .process("Resources")  // Bundle JSON configuration files
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "V7CoreTests",
            dependencies: ["V7Core"]
        ),
    ]
)
