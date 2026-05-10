//
//  SignInEmailViewModel.swift
//  DuLich
//
//  Created by Macbook Pro on 9/5/26.
//

import Foundation
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
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser (userId: authDataResult.uid, isAnonymous: authDataResult.isAnonymous, email: authDataResult.email, photoUrl: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user)    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Không tìm thấy email hoặc mật khẩu")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
