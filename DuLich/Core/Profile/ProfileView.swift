//
//  ProfileView.swift
//  DuLich
//
//  Created by Macbook Pro on 7/5/26.
//

import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws{
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List{
            if let user = viewModel.user{
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous{
                    Text("Khách: \(isAnonymous.description.capitalized)")
                }
            }
        }
        .task {
            do {
                try await viewModel.loadCurrentUser()
                print("USER:", viewModel.user)
            } catch {
                print("PROFILE ERROR:", error.localizedDescription)
            }
        }
        .navigationTitle(Text("Profile"))
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink{
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                }
            }
        }
    }


#Preview {
    NavigationStack{
        ProfileView(showSignInView: .constant(false))
    }
}
