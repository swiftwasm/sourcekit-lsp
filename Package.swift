// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SourceKitLSP",
    products: [
      .executable(
        name: "sourcekit-lsp",
        targets: ["sourcekit-lsp"]
      ),
      .library(
        name: "LSPBindings",
        type: .static,
        targets: [
          "LanguageServerProtocol",
          "LanguageServerProtocolJSONRPC",
        ]
      )
    ],
    dependencies: [
      // See 'Dependencies' below.
    ],
    targets: [
      .target(
        name: "sourcekit-lsp",
        dependencies: [
          "ArgumentParser",
          "LanguageServerProtocolJSONRPC",
          "SourceKit",
          "SwiftToolsSupport-auto",
        ]
      ),

      .target(
        name: "SourceKit",
        dependencies: [
          "Csourcekitd",
          "BuildServerProtocol",
          "IndexStoreDB",
          "LanguageServerProtocol",
          "LanguageServerProtocolJSONRPC",
          "SKCore",
          "SKSwiftPMWorkspace",
          "SwiftToolsSupport-auto",
        ]
      ),

      .target(
        name: "SKTestSupport",
        dependencies: [
          "ISDBTestSupport",
          "LSPTestSupport",
          "SourceKit",
          "tibs", // Never imported, needed at runtime
          "SwiftToolsSupport-auto",
        ]
      ),
      .testTarget(
        name: "SourceKitTests",
        dependencies: [
          "SKTestSupport",
          "SourceKit",
        ]
      ),

      .target(
        name: "SKSwiftPMWorkspace",
        dependencies: [
          "BuildServerProtocol",
          "LanguageServerProtocol",
          "SKCore",
          "SwiftPM-auto",
        ]
      ),
      .testTarget(
        name: "SKSwiftPMWorkspaceTests",
        dependencies: [
          "SKSwiftPMWorkspace",
          "SKTestSupport",
          "SwiftToolsSupport-auto",
        ]
      ),

      // Csourcekitd: C modules wrapper for sourcekitd.
      .target(
        name: "Csourcekitd",
        dependencies: []
      ),

      // SKCore: Data structures and algorithms useful across the project, but not necessarily
      // suitable for use in other packages.
      .target(
        name: "SKCore",
        dependencies: [
          "BuildServerProtocol",
          "LanguageServerProtocol",
          "LanguageServerProtocolJSONRPC",
          "SKSupport",
          "SwiftToolsSupport-auto",
        ]
      ),
      .testTarget(
        name: "SKCoreTests",
        dependencies: [
          "SKCore",
          "SKTestSupport",
        ]
      ),

      // Logging support used in LSP modules.
      .target(
        name: "LSPLogging",
        dependencies: []
      ),

      .testTarget(
        name: "LSPLoggingTests",
        dependencies: [
          "LSPLogging",
        ]
      ),

      .target(
        name: "LSPTestSupport",
        dependencies: [
          "LanguageServerProtocol",
          "LanguageServerProtocolJSONRPC"
        ]
      ),

      // jsonrpc: LSP connection using jsonrpc over pipes.
      .target(
        name: "LanguageServerProtocolJSONRPC",
        dependencies: [
          "LanguageServerProtocol",
          "LSPLogging",
        ]
      ),
      .testTarget(
        name: "LanguageServerProtocolJSONRPCTests",
        dependencies: [
          "LanguageServerProtocolJSONRPC",
          "LSPTestSupport"
        ]
      ),

      // LanguageServerProtocol: The core LSP types, suitable for any LSP implementation.
      .target(
        name: "LanguageServerProtocol",
        dependencies: []
      ),
      .testTarget(
        name: "LanguageServerProtocolTests",
        dependencies: [
          "LanguageServerProtocol",
          "LSPTestSupport",
        ]
      ),

      // BuildServerProtocol: connection between build server and language server to provide build and index info
      .target(
        name: "BuildServerProtocol",
        dependencies: [
          "LanguageServerProtocol"
        ]
      ),

      // SKSupport: Data structures, algorithms and platform-abstraction code that might be generally
      // useful to any Swift package. Similar in spirit to SwiftPM's Basic module.
      .target(
        name: "SKSupport",
        dependencies: [
          "SwiftToolsSupport-auto"
        ]
      ),
      .testTarget(
        name: "SKSupportTests",
        dependencies: [
          "LSPTestSupport",
          "SKSupport",
          "SKTestSupport",
        ]
      ),
    ]
)

// MARK: Dependencies

// When building with the swift build-script, use local dependencies whose contents are controlled
// by the external environment. This allows sourcekit-lsp to take advantage of the automation used
// for building the swift toolchain, such as `update-checkout`, or cross-repo PR tests.

#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

if getenv("SWIFTCI_USE_LOCAL_DEPS") == nil {
  // Building standalone.
  package.dependencies += [
    .package(url: "https://github.com/apple/indexstore-db.git", .branch("master")),
    .package(url: "https://github.com/apple/swift-package-manager.git", .branch("master")),
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("master")),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
  ]
} else {
  package.dependencies += [
    .package(path: "../indexstore-db"),
    .package(path: "../swiftpm"),
    .package(path: "../swiftpm/swift-tools-support-core"),
    .package(path: "../swift-argument-parser")
  ]
}
