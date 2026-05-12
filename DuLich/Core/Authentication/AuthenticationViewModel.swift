// AuthenticationViewModel.swift
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {

    /// Sign in with Google using your SignInGoogle + AuthenticationManager flow.
    /// Returns the AuthDataResultModel produced by your AuthenticationManager.
    func signInGoogle() async throws -> AuthDataResultModel {
        do {
            print("[AuthVM] start Google sign-in")
            let sIG = SignInGoogle()
            let tokens = try await sIG.signIn()
            print("[AuthVM] got tokens from SignInGoogle")

            // Use your AuthenticationManager which returns AuthDataResultModel
            let authDataResultModel = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
            print("[AuthVM] AuthenticationManager.signInWithGoogle success, uid:", authDataResultModel.uid)

            // Ensure user record exists (your existing flow)
            let user = DBUser(
                userid: authDataResultModel.uid,
                isAnonymous: authDataResultModel.isAnonymous,
                email: authDataResultModel.email,
                photoUrl: authDataResultModel.photoUrl,
                dateCreated: Date()
            )
            try await UserManager.shared.createNewUser(user: user)
            print("[AuthVM] ensured DBUser created for uid:", authDataResultModel.uid)

            return authDataResultModel
        } catch {
            print("[AuthVM] signInGoogle error:", error.localizedDescription)
            throw error
        }
    }

    /// Sign in anonymously and return the AuthDataResultModel from your AuthenticationManager.
    func signInAnonymous() async throws -> AuthDataResultModel {
        do {
            print("[AuthVM] start anonymous sign-in")
            let authDataResultModel = try await AuthenticationManager.shared.signInAnonymous()
            print("[AuthVM] anonymous sign-in success, uid:", authDataResultModel.uid)

            let user = DBUser(
                userid: authDataResultModel.uid,
                isAnonymous: authDataResultModel.isAnonymous,
                email: authDataResultModel.email,
                photoUrl: authDataResultModel.photoUrl,
                dateCreated: Date()
            )
            try await UserManager.shared.createNewUser(user: user)
            print("[AuthVM] ensured DBUser created for anonymous uid:", authDataResultModel.uid)

            return authDataResultModel
        } catch {
            print("[AuthVM] signInAnonymous error:", error.localizedDescription)
            throw error
        }
    }
}
