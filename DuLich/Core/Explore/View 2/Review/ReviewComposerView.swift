//
//  ReviewComposer.swift
//  Hotelia
//
//  Created by Macbook Pro on 14/5/26.
//

import SwiftUI
import FirebaseAuth
import Combine

struct ReviewComposerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var authorName: String = Auth.auth().currentUser?.displayName ?? ""
    @State private var rating: Int = 5
    @State private var comment: String = ""
    var onSubmit: (String, Double, String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("Đánh giá")
                        .font(.headline)
                    Spacer()
                }

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title3)
                            .onTapGesture { rating = i }
                    }
                }

                TextField("Tên của bạn", text: $authorName)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $comment)
                    .frame(height: 160)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))

                Spacer()
            }
            .padding()
            .navigationTitle("Viết đánh giá")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gửi") {
                        onSubmit(authorName.isEmpty ? "Khách" : authorName, Double(rating), comment)
                        dismiss()
                    }
                    .disabled(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
            }
        }
    }
}
