//
//  ReviewComposer.swift
//  Hotelia
//
//  Created by Macbook Pro on 14/5/26.
//

import SwiftUI
import FirebaseAuth

struct ReviewComposerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var authorName: String = Auth.auth().currentUser?.displayName ?? ""
    @State private var rating: Int = 5
    @State private var comment: String = ""
    var onSubmit: (String, Double, String) -> Void

    var body: some View {
        ZStack {
            Glass.pageBg.ignoresSafeArea()

            Circle()
                .fill(Glass.blobBlue.opacity(0.30))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -120, y: -200)
                .ignoresSafeArea()

            Circle()
                .fill(Glass.blobPurple.opacity(0.22))
                .frame(width: 240, height: 240)
                .blur(radius: 70)
                .offset(x: 130, y: 300)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)

                    Text("Viết đánh giá")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Glass.textPrimary)

                    VStack(alignment: .leading, spacing: 14) {

                        SectionHeader(title: String(localized:"star_rate"))

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= rating ? "star.fill" : "star")
                                    .font(.system(size: 28))
                                    .foregroundStyle(i <= rating ? Color.orange : Glass.textTertiary)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) { rating = i }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                    }
                    .padding(18)
                    .glassCard()

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: String(localized:"your_name"))
                        TextField("enter_name", text: $authorName)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(Glass.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.72))
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Glass.cardStroke2, lineWidth: 0.8))
                            )
                    }
                    .padding(18)
                    .glassCard()

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: String(localized: "com_ment"))
                        TextEditor(text: $comment)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(Glass.textPrimary)
                            .frame(minHeight: 140)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.72))
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Glass.cardStroke2, lineWidth: 0.8))
                            )
                    }
                    .padding(18)
                    .glassCard()

                    HStack(spacing: 12) {
                        Button { dismiss() } label: {
                            Text("Hủy")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Glass.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: Glass.cornerMd)
                                        .fill(Color.white.opacity(0.55))
                                        .overlay(RoundedRectangle(cornerRadius: Glass.cornerMd)
                                            .strokeBorder(Glass.cardStroke2, lineWidth: 0.8))
                                )
                        }

                        Button {
                            onSubmit(authorName.isEmpty ? "Khách" : authorName, Double(rating), comment)
                            dismiss()
                        } label: {
                            Text("Gửi")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: Glass.cornerMd)
                                        .fill(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                              ? Glass.accent.opacity(0.35)
                                              : Glass.accent)
                                        .shadow(color: Glass.accent.opacity(0.30), radius: 10, x: 0, y: 5)
                                )
                        }
                        .disabled(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 4)

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}
