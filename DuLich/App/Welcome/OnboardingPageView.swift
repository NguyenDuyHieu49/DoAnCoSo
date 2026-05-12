// OnboardingPageView.swift
import SwiftUI

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            if UIImage(named: page.imageName) != nil {
                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .cornerRadius(12)
                    .shadow(radius: 6)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 320)
                    .overlay(
                        Image(systemName: "airplane")
                            .font(.system(size: 64))
                            .foregroundColor(.blue.opacity(0.8))
                    )
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
