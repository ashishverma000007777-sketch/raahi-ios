// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RaahiIOS",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RaahiIOS",
            targets: ["RaahiIOS"]
        )
    ],
    dependencies: [
        // External dependencies can be declared here if building via SPM standalone
    ],
    targets: [
        .target(
            name: "RaahiIOS",
            dependencies: [],
            path: "RaahiIOS"
        ),
        .testTarget(
            name: "RaahiIOSTests",
            dependencies: ["RaahiIOS"],
            path: "Tests/RaahiIOSTests"
        )
    ]
)
