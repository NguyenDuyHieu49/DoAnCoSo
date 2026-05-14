// WelcomeView.swift
import SwiftUI

struct WelcomeView: View {
    var onFinish: (() -> Void)?

    @EnvironmentObject private var authState: AuthState
    @State private var selection: Int = 0
    @State private var showSignIn: Bool = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(title: "Chào mừng đến với Hotelia", subtitle: "Tìm khách sạn, đặt phòng và khám phá điểm đến yêu thích.", imageName: "welcome_hero"),
        OnboardingPage(title: "Tìm kiếm nhanh", subtitle: "Bộ lọc thông minh giúp bạn tìm phòng phù hợp trong vài giây.", imageName: "search"),
        OnboardingPage(title: "Quản lý lịch sử", subtitle: "Lưu trữ và xem lại các đặt phòng đã thực hiện.", imageName: "history")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TabView(selection: $selection) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                        OnboardingPageView(page: page)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(maxHeight: 520)

                VStack(spacing: 12) {
                    Text(pages[selection].title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text(pages[selection].subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 8)
                .onAppear {
                    print("WelcomeView appeared")
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        if selection < pages.count - 1 {
                            withAnimation { selection += 1 }
                        } else {
                            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                            onFinish?()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(selection == pages.count - 1 ? "Bắt đầu khám phá" : "Tiếp tục")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    HStack(spacing: 12) {
                        Button(action: {
                            showSignIn = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text("Đăng nhập")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding()
                            .background(Color(.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                        }

                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                            onFinish?()
                        }) {
                            HStack {
                                Image(systemName: "person.fill.questionmark")
                                Text("Tiếp tục với khách")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
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
