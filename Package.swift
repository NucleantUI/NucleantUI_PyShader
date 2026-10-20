// swift-tools-version: 6.2

import PackageDescription
import Foundation

/// The sibling checkouts (`../NucleantUI`, `../PyShader`) under
/// `NUCLEANT_LOCAL_DEV=1`, as every Nucleant package reads it; their
/// releases on GitHub otherwise.
let localDev = ["1", "true", "yes"].contains(
    (ProcessInfo.processInfo.environment["NUCLEANT_LOCAL_DEV"] ?? "").lowercased()
)

func nucleantDependencies() -> [Package.Dependency] {
    if localDev {
        return ["NucleantUI", "PyShader"].map { .package(path: "../\($0)") }
    }
    return [
        .package(url: "https://github.com/NucleantUI/NucleantUI.git", .upToNextMinor(from: "0.0.3")),
        .package(url: "https://github.com/NucleantUI/PyShader.git", .upToNextMinor(from: "0.0.4")),
    ]
}

let package = Package(
    name: "NucleantUI_PyShader",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "NucleantUI_PyShader", targets: ["NucleantUI_PyShader"]),
    ],
    dependencies: nucleantDependencies(),
    targets: [
        // PyShader source compiled at run time into a NucleantUI
        // `ShaderProtocol`. NucleantUI itself knows only SPIR-V.
        .target(
            name: "NucleantUI_PyShader",
            dependencies: [
                .product(name: "NucleantUI", package: "NucleantUI"),
                .product(name: "PyShader", package: "PyShader"),
            ]
        ),
        .testTarget(
            name: "NucleantUI_PyShaderTests",
            dependencies: ["NucleantUI_PyShader"]
        ),
    ]
)
