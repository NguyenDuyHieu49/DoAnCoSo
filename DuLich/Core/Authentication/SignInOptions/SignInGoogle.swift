//
//  SignInGoogle.swift
//  DuLich
//
//  Created by Macbook Pro on 8/5/26.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel{
    let idToken: String
    let accessToken: String
}

final class SignInGoogle {
    @MainActor
    func signIn()async throws -> GoogleSignInResultModel{
        guard let topViewController = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
    
}
