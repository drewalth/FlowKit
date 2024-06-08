// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FlowKit",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "FlowKit",
      targets: ["FlowKit"]),
  ],
  targets: [
    .target(
      name: "FlowKit"),
    .testTarget(
      name: "FlowKitTests",
      dependencies: ["FlowKit"]),
  ])
