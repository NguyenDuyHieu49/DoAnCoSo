// SignInEmailView.swift
import SwiftUI
import Combine

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Explicit Binding to viewModel.email
            TextField("Email", text: Binding(
                get: { viewModel.email },
                set: { viewModel.email = $0 }
            ))
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // Explicit Binding to viewModel.password
            SecureField("Password", text: Binding(
                get: { viewModel.password },
                set: { viewModel.password = $0 }
            ))
            .textContentType(.password)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            Button(action: {
                Task {
                    // Gọi đúng tên hàm trong ViewModel: signup() và signin()
                    do {
                        try await viewModel.signup()
                        showSignInView = false
                        return
                    } catch {
                        print("signup error:", error)
                    }
                    do {
                        try await viewModel.signin()
                        showSignInView = false
                        return
                    } catch {
                        print("signin error:", error)
                    }
                }
            }, label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            })

            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
