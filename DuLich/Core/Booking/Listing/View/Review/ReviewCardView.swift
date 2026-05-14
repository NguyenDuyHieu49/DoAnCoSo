//
//  ReviewCardView.swift
//  Hotelia
//
//  Created by Macbook Pro on 14/5/26.
//

import SwiftUI

struct ReviewCardView: View {
    let review: Review
    let onLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(Text(String(review.authorName.prefix(1))).font(.headline))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(review.authorName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", review.rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(review.comment)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text(review.createdAt, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: onLike) {
                            HStack(spacing: 6) {
                                Image(systemName: review.isLikedByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup")
                                Text("\(review.likes)")
                            }
                            .font(.caption2)
                            .padding(6)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
