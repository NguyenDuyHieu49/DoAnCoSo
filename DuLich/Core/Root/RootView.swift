//
//  RootView.swift
//  DuLich
//
//  Created by Macbook Pro on 6/5/26.
//

import SwiftUI
struct RootView: View {
    
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack{
            if !showSignInView{
                NavigationStack{
                    ProfileView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
  }
}
    struct RootViewPreview: PreviewProvider {
        static var previews: some View {
            RootView()
        }
    }

