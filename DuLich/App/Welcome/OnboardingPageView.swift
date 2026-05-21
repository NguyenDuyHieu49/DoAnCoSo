// OnboardingPageView.swift
import SwiftUI

struct OnboardingPage {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let imageName: String?}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            if let name = page.imageName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .cornerRadius(12)
                    .shadow(radius: 6)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 320)
                    .overlay(
                        Image("Onboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .cornerRadius(12)
                            .shadow(radius: 6)
                    )
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}
