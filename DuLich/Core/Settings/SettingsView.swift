//
//  SettingsView.swift
//  DuLich
//
//  Created by Macbook Pro on 7/5/26.
//

import SwiftUI
import Combine
@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProvider(){
            authProviders = providers
        }
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
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func updatePassword()async throws{
        let password = "123456"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List{
            Button("Đăng xuất"){
                Task{
                    do{
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            Button(role: .destructive) {
                Task{
                    do{
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }label: {
                    Text("Xoá tài khoản")
            }
            
            if viewModel.authProviders.contains(.email){
                emailSection
            }
        }
        .onAppear{
            viewModel.loadAuthProviders()
        }
        .navigationTitle(Text("Cài đặt"))
    }
}

#Preview {
    NavigationStack{
        SettingsView(showSignInView: .constant(false))
    }
}
extension SettingsView{
    private var emailSection: some View{
        Section(header: Text("Email")) {
            Button("Thiết lập lại mật khẩu"){
                Task{
                    do{
                        try await viewModel.resetPassword()
                        print("Đã thiết lập lại mật khẩu")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Cập nhật mật khẩu"){
                Task{
                    do{
                        try await viewModel.updatePassword()
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Cập nhật Email"){
                Task{
                    do{
                        try await viewModel.updateEmail()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
