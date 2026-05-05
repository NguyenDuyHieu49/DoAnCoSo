import SwiftUI

enum AppFont {
    static func heading(size: CGFloat = 28) -> Font {
        return .system(size: size, weight: .semibold)
    }
    static func subtitle(size: CGFloat = 14) -> Font {
        return .system(size: size, weight: .regular)
    }
    static func body(size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .regular)
    }
    static func button(size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .semibold)
    }
}
