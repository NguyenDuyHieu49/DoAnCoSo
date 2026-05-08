//
//  WeatherEffect.swift
//  DuLich
//
//  Created by Macbook Pro on 2/5/26.
//

import SwiftUI

// Simple rain effect using Canvas and moving lines
struct RainEffect: View {
    @State private var offsetY: CGFloat = -200

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let columns = Int(size.width / 12)
                for i in 0..<columns {
                    var path = Path()
                    let x = CGFloat(i) * 12 + (CGFloat.random(in: 0...8))
                    path.move(to: CGPoint(x: x, y: offsetY.truncatingRemainder(dividingBy: size.height)))
                    path.addLine(to: CGPoint(x: x + 2, y: offsetY.truncatingRemainder(dividingBy: size.height) + 18))
                    context.stroke(path, with: .color(Color.white.opacity(0.18)), lineWidth: 1.2)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                    offsetY += geo.size.height + 400
                }
            }
        }
        .blendMode(.screen)
    }
}

// Simple snow effect using falling circles
struct SnowEffect: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
                        .position(x: CGFloat.random(in: 0...geo.size.width), y: animate ? geo.size.height + 20 : -20)
                        .animation(.linear(duration: Double.random(in: 3.5...7)).repeatForever(autoreverses: false).delay(Double.random(in: 0...2)), value: animate)
                }
            }
            .onAppear { animate = true }
        }
        .blendMode(.screen)
    }
}

// Sun rays subtle effect
struct SunRaysEffect: View {
    @State private var rotate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<8) { i in
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.yellow.opacity(0.18), Color.clear], startPoint: .top, endPoint: .bottom))
                        .frame(width: geo.size.width * 0.6, height: 6)
                        .offset(x: 0, y: -geo.size.height * 0.15)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
            }
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotate)
            .onAppear { rotate = true }
        }
        .blendMode(.plusLighter)
    }
}
