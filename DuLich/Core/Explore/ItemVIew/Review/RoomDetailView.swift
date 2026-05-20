//
//  RoomDetailView.swift
//  Hotelia
//
//  Created by Macbook Pro on 20/5/26.
//

import SwiftUI

struct RoomDetailView: View {
    let roomName: String
    let price: Double
    let listing: Listing

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.96, blue: 1.00).ignoresSafeArea()
            Circle()
                .fill(Color(red: 0.55, green: 0.75, blue: 1.00).opacity(0.30))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 80, y: -50)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)

                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Glass.accentLight)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Glass.cardStroke2, lineWidth: 0.8))
                                .frame(width: 60, height: 60)
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Glass.accent)
                        }
                        Text(roomName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Glass.textPrimary)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(price))")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Glass.accent)
                            Text("VNĐ / đêm")
                                .font(.system(size: 13))
                                .foregroundStyle(Glass.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.alignleft").foregroundStyle(Glass.accent)
                            Text("Mô tả phòng")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Glass.textPrimary)
                        }
                        Text("Phòng khách sạn được thiết kế theo phong cách hiện đại và sang trọng, mang lại cảm giác ấm cúng nhưng vẫn đầy đủ tiện nghi. Không gian phòng rộng rãi với giường lớn êm ái, chăn ga sạch sẽ và ánh đèn vàng dịu nhẹ tạo cảm giác thư giãn cho khách lưu trú. Cửa sổ lớn giúp đón ánh sáng tự nhiên và mở ra khung cảnh đẹp của thành phố. Trong phòng được trang bị đầy đủ các tiện ích như điều hòa, tivi màn hình phẳng, wifi tốc độ cao, minibar và bàn làm việc.")
                            .font(.system(size: 14))
                            .foregroundStyle(Glass.textSecondary)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .glassCard()
                    .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}
