// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - Asset Catalogs

public enum DesignSystemSharedAsset: Sendable {
  public static let bicycle = DesignSystemSharedImages(name: "bicycle")
  public static let bicycleDefault = DesignSystemSharedImages(name: "bicycleDefault")
  public static let ecoProduct = DesignSystemSharedImages(name: "ecoProduct")
  public static let ecoProductDefault = DesignSystemSharedImages(name: "ecoProductDefault")
  public static let plogging = DesignSystemSharedImages(name: "plogging")
  public static let ploggingDefault = DesignSystemSharedImages(name: "ploggingDefault")
  public static let publicTransit = DesignSystemSharedImages(name: "publicTransit")
  public static let publicTransitDefault = DesignSystemSharedImages(name: "publicTransitDefault")
  public static let recycle = DesignSystemSharedImages(name: "recycle")
  public static let recycleDefault = DesignSystemSharedImages(name: "recycleDefault")
  public static let refillStation = DesignSystemSharedImages(name: "refillStation")
  public static let refillStationDefault = DesignSystemSharedImages(name: "refillStationDefault")
  public static let reusableContainer = DesignSystemSharedImages(name: "reusableContainer")
  public static let reusableContainerDefault = DesignSystemSharedImages(name: "reusableContainerDefault")
  public static let reusableCup = DesignSystemSharedImages(name: "reusableCup")
  public static let reusableCupDefault = DesignSystemSharedImages(name: "reusableCupDefault")
  public static let vegan = DesignSystemSharedImages(name: "vegan")
  public static let veganDefault = DesignSystemSharedImages(name: "veganDefault")
  public static let notificationIcon = DesignSystemSharedImages(name: "NotificationIcon")
  public static let searchIcon = DesignSystemSharedImages(name: "SearchIcon")
  public static let agreeCheckIcon = DesignSystemSharedImages(name: "agreeCheckIcon")
  public static let agreeCheckIconSelected = DesignSystemSharedImages(name: "agreeCheckIconSelected")
  public static let characterBlue = DesignSystemSharedImages(name: "characterBlue")
  public static let characterGreen = DesignSystemSharedImages(name: "characterGreen")
  public static let characterRed = DesignSystemSharedImages(name: "characterRed")
  public static let clearIcon = DesignSystemSharedImages(name: "clearIcon")
  public static let dropDownIcon = DesignSystemSharedImages(name: "dropDownIcon")
  public static let locationIcon = DesignSystemSharedImages(name: "locationIcon")
  public static let nonprimaryCheckIcon = DesignSystemSharedImages(name: "nonprimaryCheckIcon")
  public static let normalCheckIcon = DesignSystemSharedImages(name: "normalCheckIcon")
  public static let primaryCheckIcon = DesignSystemSharedImages(name: "primaryCheckIcon")
  public static let toastCheckIcon = DesignSystemSharedImages(name: "toastCheckIcon")
  public static let warningIcon = DesignSystemSharedImages(name: "warningIcon")
  public static let challengeBox = DesignSystemSharedColors(name: "challengeBox")
  public static let challengeLine = DesignSystemSharedColors(name: "challengeLine")
  public static let feedLabel = DesignSystemSharedColors(name: "feedLabel")
  public static let maskGroup = DesignSystemSharedImages(name: "Mask group")
  public static let iconBadge = DesignSystemSharedImages(name: "icon-badge")
  public static let iconCheck = DesignSystemSharedImages(name: "icon-check")
  public static let iconPoint = DesignSystemSharedImages(name: "icon-point")
  public static let iconStar = DesignSystemSharedImages(name: "icon-star")
  public static let iconSettings = DesignSystemSharedImages(name: "icon_settings")
  public static let iconamoonNotificationBold = DesignSystemSharedImages(name: "iconamoon_notification-bold")
  public static let typoLogo = DesignSystemSharedImages(name: "typoLogo")
}

// MARK: - Implementation Details

public final class DesignSystemSharedColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension DesignSystemSharedColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: DesignSystemSharedColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: DesignSystemSharedColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct DesignSystemSharedImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: DesignSystemSharedImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: DesignSystemSharedImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: DesignSystemSharedImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
