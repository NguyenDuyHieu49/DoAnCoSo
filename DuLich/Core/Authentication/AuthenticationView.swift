//
//  AuthenticationView.swift
//  DuLich
//
//  Created by Macbook Pro on 7/5/26.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Combine
import FirebaseAuth


struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            
            Button(action:{
                Task{
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            },label: {
                Text("Đăng nhập với tư cách khách")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .leading) {
                        
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 20)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
        )
            
            NavigationLink{
                SignInEmailView(showSignInView: $showSignInView)
            }label: {
                Text("Đăng nhập với Email")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment:.leading){
                        Image (systemName: "envelope")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 20)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {

                Text("Đăng nhập với Google")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .leading) {

                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 20)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    }
            }
            Spacer()
        }.padding()
            .navigationTitle("Đăng nhập")

    }
}

#Preview {
    NavigationStack{
        AuthenticationView(showSignInView: .constant(false))
    }
}
