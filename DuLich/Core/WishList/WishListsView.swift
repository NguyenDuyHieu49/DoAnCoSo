//
//  WishlistsView.swift
//  BookingApp
//
//  Created by Macbook Pro on 27/4/26.
//

import SwiftUI

struct WishlistsView: View {
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 32){
                VStack{
                    Text("Đăng nhập để xem danh sách mơ ước của bạn")
                        .font(.headline)
                    
                    Text("Bạn có thể tạo và sắp xếp danh sách mơ ước của bạn ở đây khi đã tạo tài khoản")
                        .font(.footnote)
                }
                Button {
                    print("Đăng nhập")
                } label: {
                    Text("Đăng nhập")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 360, height: 48)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(Text("Danh sách mơ ước"))
        }
    }
}

#Preview {
    WishlistsView()
}
