
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ComputerUse",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/google/generative-ai-swift", .upToNextMajor(from: "0.4.4")),
    ],
    targets: [
        .target(
            name: "ComputerUse",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
            ],
            path: "Sources/main"),
        .testTarget(
            name: "ComputerUseTests",
            dependencies: ["ComputerUse"],
            path: "Tests/mainTests"),
    ]
)
