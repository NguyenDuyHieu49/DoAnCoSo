//
//  AuthenticationViewModel.swift
//  DuLich
//
//  Created by Macbook Pro on 9/5/26.
//

import Foundation
import Combine
@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws{
        let sIG = SignInGoogle()
        let tokens = try await sIG.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser (userid: authDataResult.uid, isAnonymous: authDataResult.isAnonymous, email: authDataResult.email, photoUrl: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user)    }
    
    func signInAnonymous() async throws{
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser (userid: authDataResult.uid, isAnonymous: authDataResult.isAnonymous, email: authDataResult.email, photoUrl: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user)
    }
}
