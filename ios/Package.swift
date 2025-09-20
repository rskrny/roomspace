// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "RoomSpace",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RoomSpace",
            targets: ["RoomSpace"]),
    ],
    dependencies: [
        // Dependencies for HTTP requests and JSON handling
    ],
    targets: [
        .target(
            name: "RoomSpace",
            dependencies: []),
        .testTarget(
            name: "RoomSpaceTests",
            dependencies: ["RoomSpace"]),
    ]
)