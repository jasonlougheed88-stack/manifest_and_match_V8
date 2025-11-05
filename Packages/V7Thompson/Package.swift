// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "V7Thompson",
    platforms: [
        .iOS(.v18),      // iOS-only target for 357x Thompson iPhone performance optimization
        .macOS(.v15)     // macOS 15.0 required for V7Embeddings dependency and testing
    ],
    products: [
        // Thompson Sampling algorithm implementation with mathematical corrections
        .library(
            name: "V7Thompson",
            targets: ["V7Thompson"]
        ),
    ],
    dependencies: [
        // V7Core dependency for ThompsonMonitorable protocol conformance
        .package(path: "../V7Core"),
        // V7Embeddings for semantic similarity enhancement (Phase 2A)
        .package(path: "../V7Embeddings"),
    ],
    targets: [
        // V7Thompson contains the corrected Thompson Sampling algorithm
        .target(
            name: "V7Thompson",
            dependencies: [
                "V7Core",
                "V7Embeddings"  // Phase 2A: Semantic enhancement
            ],
            exclude: ["README_Phase8.2.md"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")  // Swift 6 strict concurrency (Week 0 Pre-Task 0.1)
            ]
        ),
        .testTarget(
            name: "V7ThompsonTests",
            dependencies: ["V7Thompson"],
            exclude: [
                "Phase8FinalValidation.swift"  // Script file, not a test
            ]
        ),
    ]
)
