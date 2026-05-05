import SwiftUI

struct CreateAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isFormValid: Bool = false
    
    private func validateForm() {
        isFormValid = !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Top bar with back arrow and status-like spacing
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.cardShadow, radius: 6, x: 0, y: 4)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tạo tài khoản")
                            .font(AppFont.heading(size: 28))
                            .foregroundColor(.red)
                        
                        Text("Một bước nữa để chạm tới sự thư giãn!")
                            .font(AppFont.subtitle(size: 14))
                            .foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Form
                    VStack(spacing: 16) {
                        InputFieldView(label: "Tên người dùng", placeholder: "Nhập tên của bạn", text: $fullName, autocapitalization: .words)
                        InputFieldView(label: "E-mail", placeholder: "Nhập e-mail của bạn", text: $email, keyboardType: .emailAddress, autocapitalization: .never)
                        PasswordFieldView(label: "Mật khẩu", placeholder: "Nhập mật khẩu của bạn", password: $password)
                    }
                    .onChange(of: fullName) { validateForm() }
                    .onChange(of: email) { validateForm() }
                    .onChange(of: password) { validateForm() }
                    
                    // Primary action
                    PrimaryButton(title: "Tạo tài khoản", action: {
                        // Hook for create account action
                    }, enabled: isFormValid)
                    .padding(.top, 4)
                    
                    // Or sign in with
                    VStack(spacing: 12) {
                        Text("Hoặc đăng nhập với")
                            .font(AppFont.subtitle(size: 13))
                            .foregroundColor(.placeholder)
                        
                        HStack(spacing: 16) {
                            // Google
                            Button(action: {
                                // Google action
                            }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(width: 57, height: 57)
                                    .overlay(
                                        Image("google")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }

                            // Apple
                            SocialSignInButton(provider: .apple) {
                                // Apple action
                            }

                            // Facebook
                            Button(action: {
                                // Facebook action
                            }) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 57, height: 57)
                                    .overlay(
                                        Image("facebook")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                        }

                        
                        Spacer()
                        
                        // Terms
                        Text("By signing up you agree to our Terms and Conditions of Use.")
                            .font(AppFont.subtitle(size: 12))
                            .foregroundColor(.placeholder)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    struct CreateAccountView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                CreateAccountView()
                    .previewDevice("iPhone 14 Pro")
                CreateAccountView()
                    .previewDevice("iPhone SE (3rd generation)")
            }
        }
    }
}
