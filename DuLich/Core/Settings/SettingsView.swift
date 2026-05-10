//
//  SettingsView.swift
//  DuLich
//
//  Created by Macbook Pro on 7/5/26.
//

import SwiftUI
import Combine

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
            
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .onAppear{
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
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
    
    private var anonymousSection: some View{
        Section(header: Text("Liên kết với tài khoản đã có")) {
            Button("Liên kết với tài khoản Google"){
                Task{
                    do{
                        try await viewModel.linkGoogleAccount()
                        print("Liên kết thành công")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Liên kết với Email"){
                Task{
                    do{
                        try await viewModel.linkEmailAccount()
                        print("Liên kết thành công")
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
