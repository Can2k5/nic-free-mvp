import SwiftUI
import UIKit

extension Color {
    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(
            UIColor { traits in
                traits.userInterfaceStyle == .dark ? dark : light
            }
        )
    }

    private static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }

    static let appBackgroundTop = dynamic(
        light: rgb(251, 248, 245),
        dark: rgb(18, 22, 31)
    )

    static let appBackgroundBottom = dynamic(
        light: rgb(235, 230, 245),
        dark: rgb(12, 17, 24)
    )

    static let backgroundSecondary = dynamic(
        light: rgb(244, 247, 251),
        dark: rgb(20, 25, 35)
    )

    static let cardBackground = dynamic(
        light: rgb(255, 252, 255, 0.92),
        dark: rgb(34, 40, 54, 0.94)
    )

    static let surface = dynamic(
        light: rgb(255, 252, 255, 0.84),
        dark: rgb(32, 38, 52, 0.9)
    )

    static let surfaceElevated = dynamic(
        light: rgb(255, 253, 255, 0.95),
        dark: rgb(40, 47, 63, 0.96)
    )

    static let surfaceMuted = dynamic(
        light: rgb(255, 255, 255, 0.64),
        dark: rgb(44, 52, 68, 0.84)
    )

    static let cardSecondary = dynamic(
        light: rgb(247, 250, 252, 0.92),
        dark: rgb(37, 44, 59, 0.92)
    )

    static let inputBackground = dynamic(
        light: rgb(255, 253, 255, 0.97),
        dark: rgb(30, 36, 48, 0.98)
    )

    static let onboardingSurface = dynamic(
        light: rgb(255, 252, 255, 0.86),
        dark: rgb(36, 41, 56, 0.92)
    )

    static let onboardingSurfaceElevated = dynamic(
        light: rgb(255, 254, 255, 0.96),
        dark: rgb(42, 48, 64, 0.97)
    )

    static let onboardingSurfaceInteractive = dynamic(
        light: rgb(247, 239, 255, 0.98),
        dark: rgb(66, 55, 108, 0.92)
    )

    static let border = dynamic(
        light: rgb(255, 255, 255, 0.46),
        dark: rgb(128, 141, 168, 0.4)
    )

    static let borderStrong = dynamic(
        light: rgb(160, 130, 229, 0.28),
        dark: rgb(162, 145, 235, 0.42)
    )

    static let divider = dynamic(
        light: rgb(214, 222, 232, 0.72),
        dark: rgb(94, 106, 129, 0.5)
    )

    static let ink = dynamic(
        light: rgb(31, 41, 59),
        dark: rgb(244, 247, 252)
    )

    static let secondaryText = dynamic(
        light: rgb(99, 109, 129),
        dark: rgb(182, 191, 209)
    )

    static let textMuted = dynamic(
        light: rgb(136, 148, 165),
        dark: rgb(142, 153, 172)
    )

    static let helperText = dynamic(
        light: rgb(126, 134, 154),
        dark: rgb(153, 162, 181)
    )

    static let accentInk = dynamic(
        light: rgb(77, 110, 115),
        dark: rgb(142, 185, 192)
    )

    static let accentWash = dynamic(
        light: rgb(232, 242, 240),
        dark: rgb(39, 52, 58)
    )

    static let mist = dynamic(
        light: rgb(224, 237, 232),
        dark: rgb(28, 40, 43)
    )

    static let heroTop = dynamic(
        light: rgb(245, 237, 227),
        dark: rgb(44, 42, 37)
    )

    static let heroBottom = dynamic(
        light: rgb(224, 237, 235),
        dark: rgb(31, 43, 44)
    )

    static let heroSecondaryText = dynamic(
        light: rgb(89, 105, 115),
        dark: rgb(203, 210, 220)
    )

    static let heroAccent = dynamic(
        light: rgb(107, 148, 130),
        dark: rgb(124, 184, 158)
    )

    static let buttonTop = dynamic(
        light: rgb(122, 87, 220),
        dark: rgb(134, 111, 255)
    )

    static let buttonBottom = dynamic(
        light: rgb(86, 46, 214),
        dark: rgb(107, 82, 255)
    )

    static let buttonHighlight = dynamic(
        light: rgb(198, 180, 255, 0.88),
        dark: rgb(188, 177, 255, 0.72)
    )

    static let disabledButton = dynamic(
        light: rgb(196, 204, 214),
        dark: rgb(70, 79, 97)
    )

    static let disabledText = dynamic(
        light: rgb(245, 247, 250),
        dark: rgb(210, 216, 226)
    )

    static let greenBadge = dynamic(
        light: rgb(227, 245, 234),
        dark: rgb(35, 67, 48)
    )

    static let greenBadgeText = dynamic(
        light: rgb(46, 107, 71),
        dark: rgb(160, 233, 183)
    )

    static let pendingBadge = dynamic(
        light: rgb(237, 240, 245),
        dark: rgb(44, 50, 64)
    )

    static let pendingBadgeText = dynamic(
        light: rgb(107, 117, 135),
        dark: rgb(170, 180, 198)
    )

    static let shadowColor = dynamic(
        light: rgb(43, 51, 61),
        dark: rgb(0, 0, 0, 0.6)
    )

    static let onboardingShadow = dynamic(
        light: rgb(63, 41, 112, 0.18),
        dark: rgb(0, 0, 0, 0.42)
    )

    static let overlayScrim = dynamic(
        light: rgb(18, 22, 30, 0.14),
        dark: rgb(0, 0, 0, 0.34)
    )

    static let tabBarBackground = dynamic(
        light: rgb(255, 255, 255, 0.78),
        dark: rgb(15, 19, 28, 0.84)
    )
}
