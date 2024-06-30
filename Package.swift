// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "Transit Complete",
  products: [
    .library(name: "TransitOwen", targets: ["TransitOwen"])
  ],
  targets: [
    .target(
      name: "TransitOwen",
      resources: []
		),
    .testTarget(
      name: "TransitTests",
      dependencies: ["TransitOwen"],
      resources: [.process("Test Data")]
		)
  ]
)
