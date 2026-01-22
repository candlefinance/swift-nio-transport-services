// swift-tools-version:5.8
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let strictConcurrencyDevelopment = false

let strictConcurrencySettings: [SwiftSetting] = {
    var initialSettings: [SwiftSetting] = []
    initialSettings.append(contentsOf: [
        .enableUpcomingFeature("StrictConcurrency"),
        .enableUpcomingFeature("InferSendableFromCaptures"),
    ])

    if strictConcurrencyDevelopment {
        // -warnings-as-errors here is a workaround so that IDE-based development can
        // get tripped up on -require-explicit-sendable.
        initialSettings.append(.unsafeFlags(["-Xfrontend", "-require-explicit-sendable", "-warnings-as-errors"]))
    }

    return initialSettings
}()

let package = Package(
    name: "candle-swift-nio-transport-services",
    products: [
        .library(name: "CandleNIOTransportServices", targets: ["CandleNIOTransportServices"])
    ],
    dependencies: [
        .package(name: "candle-swift-nio", url: "https://github.com/candlefinance/swift-nio.git", branch: "fix-candle-2.82.1"),
        .package(name: "candle-swift-atomics", url: "https://github.com/candlefinance/swift-atomics.git", branch: "fix-candle-1.2.0"),
    ],
    targets: [
        .target(
            name: "CandleNIOTransportServices",
            dependencies: [
                .product(name: "CandleNIO", package: "candle-swift-nio"),
                .product(name: "CandleNIOCore", package: "candle-swift-nio"),
                .product(name: "CandleNIOFoundationCompat", package: "candle-swift-nio"),
                .product(name: "CandleNIOTLS", package: "candle-swift-nio"),
                .product(name: "CandleAtomics", package: "candle-swift-atomics"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .executableTarget(
            name: "NIOTSHTTPClient",
            dependencies: [
                "CandleNIOTransportServices",
                .product(name: "CandleNIOCore", package: "candle-swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "candle-swift-nio"),
            ]
        ),
        .executableTarget(
            name: "NIOTSHTTPServer",
            dependencies: [
                "CandleNIOTransportServices",
                .product(name: "CandleNIOCore", package: "candle-swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "candle-swift-nio"),
            ]
        ),
        .testTarget(
            name: "NIOTransportServicesTests",
            dependencies: [
                "CandleNIOTransportServices",
                .product(name: "CandleNIOCore", package: "candle-swift-nio"),
                .product(name: "CandleNIOEmbedded", package: "candle-swift-nio"),
                .product(name: "CandleAtomics", package: "candle-swift-atomics"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)

// ---    STANDARD CROSS-REPO SETTINGS DO NOT EDIT   --- //
for target in package.targets {
    switch target.type {
    case .regular, .test, .executable:
        var settings = target.swiftSettings ?? []
        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
        settings.append(.enableUpcomingFeature("MemberImportVisibility"))
        target.swiftSettings = settings
    case .macro, .plugin, .system, .binary:
        ()  // not applicable
    @unknown default:
        ()  // we don't know what to do here, do nothing
    }
}
// --- END: STANDARD CROSS-REPO SETTINGS DO NOT EDIT --- //
