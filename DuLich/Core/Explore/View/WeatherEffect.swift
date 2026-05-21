//
//  WeatherEffect.swift
//  DuLich
//
//  Redesigned with Glassmorphism – iOS light theme
//

import SwiftUI

// MARK: – Rain Effect
struct RainEffect: View {
    @State private var offsetY: CGFloat = -200

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let columns = Int(size.width / 10)
                for i in 0..<columns {
                    var path = Path()
                    let x = CGFloat(i) * 10 + CGFloat.random(in: 0...7)
                    let y = offsetY.truncatingRemainder(dividingBy: size.height)
                    path.move(to:    CGPoint(x: x,     y: y))
                    path.addLine(to: CGPoint(x: x + 1.5, y: y + 16))
                    context.stroke(
                        path,
                        with: .color(Color.white.opacity(0.45)),
                        lineWidth: 1.0
                    )
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                    offsetY += geo.size.height + 400
                }
            }
        }
        .blendMode(.screen)
    }
}

struct SnowEffect: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.90))
                        .frame(
                            width:  CGFloat.random(in: 3...7),
                            height: CGFloat.random(in: 3...7)
                        )
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: animate ? geo.size.height + 20 : -20
                        )
                        .animation(
                            .linear(duration: Double.random(in: 3.5...7.0))
                                .repeatForever(autoreverses: false)
                                .delay(Double.random(in: 0...2.0)),
                            value: animate
                        )
                }
            }
            .onAppear { animate = true }
        }
        .blendMode(.screen)
    }
}

struct SunRaysEffect: View {
    @State private var rotate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<8) { i in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.2).opacity(0.22),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint:   .bottom
                            )
                        )
                        .frame(width: geo.size.width * 0.55, height: 5)
                        .offset(x: 0, y: -geo.size.height * 0.14)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
            }
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .animation(
                .linear(duration: 20).repeatForever(autoreverses: false),
                value: rotate
            )
            .onAppear { rotate = true }
        }
        .blendMode(.plusLighter)
    }
}

struct OvercastEffect: View {
    @State private var offsetX: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dải mây trên
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.60).opacity(0.28),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * 0.70, height: 28)
                    .offset(x: offsetX - geo.size.width * 0.10, y: geo.size.height * 0.20)
                    .blur(radius: 6)

                // Dải mây dưới
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(white: 0.55).opacity(0.22)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * 0.55, height: 20)
                    .offset(x: -offsetX + geo.size.width * 0.20, y: geo.size.height * 0.58)
                    .blur(radius: 5)
            }
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                    offsetX = geo.size.width * 0.15
                }
            }
        }
        .blendMode(.multiply)
    }
}
