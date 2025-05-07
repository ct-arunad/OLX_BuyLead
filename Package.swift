// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OLX_BuyLeads",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "OLX_BuyLeads",
            targets: ["OLX_BuyLeads"]),
    ],
    dependencies: [
       ],
    targets: [
        .target(
            name: "OLX_BuyLeads",
            dependencies: [],
            resources: [
             //   .process("Resources"),
                .process("Resources/Images.xcassets"),
                .process("Resources/Images.xcassets/**/*.svg"),
                .process("Resources/Images.xcassets/**/*.png"),
                .process("Resources/BuyLeadOnline.plist"),
                .process("Resources/buyleadPhoneClick.plist"),
                .copy("Resources/Fonts"),
                .process("InventorySwiftModel.xcdatamodeld/InventorySwiftModel.xcdatamodel/contents")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "OLX_BuyLeadsTests",
            dependencies: ["OLX_BuyLeads"])
    ]
)
