// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ChartsColorTestPackage",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ChartsColorTestPackage",
            targets: ["ChartsColorTestPackage"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ChartsColorTestPackage",
            dependencies: []
        ),
        .testTarget(
            name: "ChartsColorTestPackageTests",
            dependencies: ["ChartsColorTestPackage"]
        ),
    ]
)