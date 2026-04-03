// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "TrashTrove",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TrashTrove",
            targets: ["TrashTrove"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TrashTrove",
            path: "TrashTrove",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TrashTroveTests",
            dependencies: ["TrashTrove"],
            path: "TrashTroveTests"
        ),
    ]
)
