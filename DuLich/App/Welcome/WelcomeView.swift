//
//  WelcomeView.swift
//  DuLich
//
import SwiftUI

struct WelcomeView: View {
    var onFinish: (() -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authState: AuthState
    @State private var selection: Int = 0
    @State private var showSignIn: Bool = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(title: "welcome_text", subtitle: "sub_welcome_1", imageName: "welcome_hero"),
        OnboardingPage(title: "welcome_text_2", subtitle: "sub_welcome_2", imageName: "search"),
        OnboardingPage(title: "welcome_text_3", subtitle: "sub_welcome_3", imageName: "history")
    ]

    private var backgroundGradient: LinearGradient {
        switch selection {
        case 0:
            return LinearGradient(
                colors: [
                    Color(red: 0.48, green: 0.72, blue: 0.98),
                    Color(red: 0.72, green: 0.88, blue: 1.00),
                    Color(red: 0.90, green: 0.95, blue: 1.00)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case 1:
            return LinearGradient(
                colors: [
                    Color(red: 0.38, green: 0.65, blue: 0.95),
                    Color(red: 0.65, green: 0.85, blue: 1.00),
                    Color(red: 0.88, green: 0.94, blue: 1.00)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.60, blue: 0.92),
                    Color(red: 0.68, green: 0.84, blue: 1.00),
                    Color(red: 0.90, green: 0.95, blue: 1.00)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.6), value: selection)

                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(x: -100, y: -200)

                Circle()
                    .fill(Color(red: 0.40, green: 0.65, blue: 1.00).opacity(0.18))
                    .frame(width: 220, height: 220)
                    .blur(radius: 55)
                    .offset(x: 120, y: 260)

                VStack(spacing: 0) {

                    TabView(selection: $selection) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                            OnboardingPageView(page: page)
                                .tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxHeight: 420)

                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == selection ? Color(.systemBackground) : Color(.systemBackground).opacity(0.40))
                                .frame(width: i == selection ? 22 : 8, height: 8)
                                .animation(.spring(response: 0.35, dampingFraction: 0.70), value: selection)
                        }
                    }
                    .padding(.top, 16)

                    VStack(spacing: 8) {
                        Text(pages[selection].title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.label))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)

                        Text(pages[selection].subtitle)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel).opacity(0.78))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                    .animation(.easeInOut(duration: 0.30), value: selection)
                    .onAppear {
                        print("WelcomeView appeared")
                    }

                    Spacer()

                    VStack(spacing: 12) {

                        Button {
                            if selection < pages.count - 1 {
                                withAnimation(.snappy) { selection += 1 }
                            } else {
                                UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                                onFinish?()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text(selection == pages.count - 1 ? "Bắt đầu khám phá" : "Tiếp tục")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                if selection == pages.count - 1 {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                Spacer()
                            }
                            .foregroundColor(Color(red: 0.15, green: 0.35, blue: 0.78))
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground).opacity(0.92))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(Color(.systemBackground), lineWidth: 1.0)
                                    )
                                    .shadow(color: Color(.systemBackground).opacity(0.10), radius: 10, x: 0, y: 5)
                            )
                        }

                        HStack(spacing: 10) {
                            Button {
                                showSignIn = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Đăng nhập")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(Color(.label))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(
                                                    colorScheme == .dark
                                                    ? Color.white.opacity(0.08)
                                                    : Color.white.opacity(0.18)
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color.white.opacity(0.55), lineWidth: 0.8)
                                        )
                                        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
                                )
                            }

                            Button {
                                UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                                onFinish?()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.fill.questionmark")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Dùng thử")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(Color(.secondaryLabel).opacity(0.80))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.8)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignIn) {
                NavigationStack {
                    AuthenticationView(showSignInView: $showSignIn, onSignInSuccess: {
                        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                        onFinish?()
                        print("WelcomeView: onSignInSuccess called — onboarding finished")
                    })
                    .environmentObject(authState)
                }
            }
        }
    }
}
#Preview {

    WelcomeView()
        .environmentObject(AuthState())
}
