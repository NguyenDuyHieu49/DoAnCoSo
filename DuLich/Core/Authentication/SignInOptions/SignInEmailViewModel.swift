// SignInEmailViewModel.swift
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    func signup() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Không tìm thấy email hoặc mật khẩu")
            return
        }

        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(
            userid: authDataResult.uid,
            isAnonymous: authDataResult.isAnonymous,
            email: authDataResult.email,
            photoUrl: authDataResult.photoUrl,
            dateCreated: Date()
        )
        try await UserManager.shared.createNewUser(user: user)
    }

    func signin() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Không tìm thấy email hoặc mật khẩu")
            return
        }

        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
