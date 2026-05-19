// AuthenticationViewModel.swift
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {

    func signInGoogle() async throws -> AuthDataResultModel {
        do {
            print("[AuthVM] start Google sign-in")
            let sIG = SignInGoogle()
            let tokens = try await sIG.signIn()
            let authDataResultModel = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
            print("[AuthVM] signInWithGoogle success, uid:", authDataResultModel.uid)
            let user = DBUser(
                userid: authDataResultModel.uid,
                isAnonymous: authDataResultModel.isAnonymous,
                email: authDataResultModel.email,
                photoUrl: authDataResultModel.photoUrl,
                dateCreated: Date()
            )
            try await UserManager.shared.createNewUser(user: user)
            return authDataResultModel
        } catch {
            print("[AuthVM] signInGoogle error:", error.localizedDescription)
            throw error
        }
    }

    func signInAnonymous() async throws -> AuthDataResultModel {
        do {
            print("[AuthVM] start anonymous sign-in")
            let authDataResultModel = try await AuthenticationManager.shared.signInAnonymous()
            let user = DBUser(
                userid: authDataResultModel.uid,
                isAnonymous: authDataResultModel.isAnonymous,
                email: authDataResultModel.email,
                photoUrl: authDataResultModel.photoUrl,
                dateCreated: Date()
            )
            try await UserManager.shared.createNewUser(user: user)
            return authDataResultModel
        } catch {
            print("[AuthVM] signInAnonymous error:", error.localizedDescription)
            throw error
        }
    }
}
