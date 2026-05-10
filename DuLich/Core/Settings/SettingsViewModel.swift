//
//  SettingsViewModel.swift
//  DuLich
//
//  Created by Macbook Pro on 9/5/26.
//

import Foundation
import Combine
@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil

    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProvider(){
            authProviders = providers
        }
    }
    
    func loadAuthUser(){
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
            
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    func updateEmail()async throws{
        let email = "another123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func updatePassword()async throws{
        let password = "123456"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws{
        let sIG = SignInGoogle()
        let tokens = try await sIG.signIn()
        let authDataResult = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        self.authUser = authDataResult
    }
    
    func linkEmailAccount() async throws{
        let email = "hello123@gmail.com"
        let password = "123456"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
}

