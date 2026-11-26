// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ComicInfoGrandComicsDatabase",
  platforms: [
    .macOS(.v27),
    .iOS(.v27),
  ],
  products: [
    .library(
      name: "ComicInfoGrandComicsDatabase",
      targets: ["ComicInfoGrandComicsDatabase"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/veganstraightedge/ComicInfo.swift.git", from: "1.10.0")
  ],
  targets: [
    .target(
      name: "ComicInfoGrandComicsDatabase",
      dependencies: [
        .product(name: "ComicInfo", package: "ComicInfo.swift")
      ]
    ),
    .testTarget(
      name: "ComicInfoGrandComicsDatabaseTests",
      dependencies: ["ComicInfoGrandComicsDatabase"],
      resources: [.copy("Fixtures")]
    ),
  ]
)
