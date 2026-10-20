// swift-tools-version: 6.2

import PackageDescription
import Foundation

// A standalone app on NucleantUI_PyShader, taken from the enclosing
// checkout. NucleantUI as NucleantUI_PyShader takes it: the sibling
// checkout under `NUCLEANT_LOCAL_DEV=1`, its release otherwise.
let localDev = ["1", "true", "yes"].contains(
    (ProcessInfo.processInfo.environment["NUCLEANT_LOCAL_DEV"] ?? "").lowercased()
)

let package = Package(
    name: "ShaderLab",
    platforms: [.macOS(.v14), .iOS(.v17)],
    dependencies: [
        .package(path: "../.."),
        localDev
            ? .package(path: "../../../NucleantUI")
            : .package(url: "https://github.com/NucleantUI/NucleantUI.git", .upToNextMinor(from: "0.0.3")),
    ],
    targets: [
        .executableTarget(
            name: "ShaderLab",
            dependencies: [
                .product(name: "NucleantUI_PyShader", package: "NucleantUI_PyShader"),
                .product(name: "NucleantUI", package: "NucleantUI"),
            ]
        ),
    ]
)
