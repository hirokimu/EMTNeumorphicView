// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EMTNeumorphicView",
    products: [
        .library(name: "EMTNeumorphicView", targets: ["EMTNeumorphicView"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "EMTNeumorphicView", path: "EMTNeumorphicView/Classes")
    ],
    swiftLanguageVersions: [.v5]
)
