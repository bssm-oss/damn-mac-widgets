// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DamnMacOSWidgets",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "DamnMacOSWidgets", targets: ["DamnMacOSWidgets"]),
    ],
    targets: [
        .executableTarget(
            name: "DamnMacOSWidgets",
            path: "Sources/DamnMacOSWidgets",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Info.plist",
                ]),
            ]
        ),
        .testTarget(
            name: "DamnMacOSWidgetsTests",
            dependencies: ["DamnMacOSWidgets"],
            path: "Tests/DamnMacOSWidgetsTests"
        ),
    ]
)
