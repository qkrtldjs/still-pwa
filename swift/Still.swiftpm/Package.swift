// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes
let package = Package(name: "Still", platforms: [.iOS("17.0")], products: [.iOSApplication(name: "Still", targets: ["Still"], bundleIdentifier: "com.example.still", teamIdentifier: "", displayVersion: "1.0", bundleVersion: "1", appIcon: .placeholder(icon: .bookmark), accentColor: .presetColor(.black), supportedDeviceFamilies: [.pad, .phone], supportedInterfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight])], targets: [.executableTarget(name: "Still", path: "Sources")])