//
//  SignInEmailView.swift
//  DuLich
//
//  Created by Macbook Pro on 7/5/26.
//

import SwiftUI
import Combine

@MainActor
final class SignInEmailModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Không tìm thấy email hoặc mật khẩu")
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Không tìm thấy email hoặc mật khẩu")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
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
