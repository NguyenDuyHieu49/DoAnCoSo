//
//  GlassStyle.swift
//  Hotelia
//
//  Created by Macbook Pro on 20/5/26.
//

import SwiftUI

enum Glass {
    static let pageBg        = Color(red: 0.92, green: 0.95, blue: 1.00)
    static let blobBlue      = Color(red: 0.55, green: 0.75, blue: 1.00)
    static let blobPurple    = Color(red: 0.75, green: 0.65, blue: 1.00)
    static let cardFill      = Color.white.opacity(0.72)
    static let cardStroke    = Color.white.opacity(0.90)
    static let cardStroke2   = Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.45)
    static let cornerXL: CGFloat = 24
    static let cornerLg: CGFloat = 18
    static let cornerMd: CGFloat = 12
    static let cornerSm: CGFloat = 8
    static let accent        = Color(red: 0.10, green: 0.44, blue: 0.95)
    static let accentLight   = Color(red: 0.10, green: 0.44, blue: 0.95).opacity(0.10)
    static let pink          = Color(red: 0.95, green: 0.22, blue: 0.50)
    static let pinkLight     = Color(red: 0.95, green: 0.22, blue: 0.50).opacity(0.10)
    static let green         = Color(red: 0.13, green: 0.72, blue: 0.44)
    static let greenLight    = Color(red: 0.13, green: 0.72, blue: 0.44).opacity(0.10)
    static let textPrimary   = Color(red: 0.08, green: 0.10, blue: 0.18)
    static let textSecondary = Color(red: 0.35, green: 0.40, blue: 0.55)
    static let textTertiary  = Color(red: 0.55, green: 0.60, blue: 0.72)
}

struct GlassCard: ViewModifier {
    var radius: CGFloat = Glass.cornerLg
    var prominent: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(Glass.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(prominent ? Glass.cardStroke : Glass.cardStroke2, lineWidth: prominent ? 1.2 : 0.8)
                    )
                    .shadow(color: Color(red: 0.55, green: 0.70, blue: 1.00).opacity(0.12), radius: 12, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            )
    }
}

extension View {
    func glassCard(radius: CGFloat = Glass.cornerLg, prominent: Bool = false) -> some View {
        modifier(GlassCard(radius: radius, prominent: prominent))
    }

    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Glass.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
