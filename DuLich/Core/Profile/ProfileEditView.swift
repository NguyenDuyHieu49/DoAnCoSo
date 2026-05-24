//
//  ProfileEditView.swift
//  Hotelia
//
//  Created by Macbook Pro on 24/5/26.
//
import SwiftUI

struct ProfileEditView: View {
    @Binding var user: DBUser?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ProfileEditViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.75, blue: 1.0),
                    Color(red: 0.75, green: 0.88, blue: 1.0),
                    Color(red: 0.88, green: 0.93, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 65)
                .offset(x: -110, y: -180)

            Circle()
                .fill(Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.22))
                .frame(width: 200, height: 200)
                .blur(radius: 52)
                .offset(x: 130, y: 220)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {

                    sectionCard(title: "personal_information", icon: "person.fill") {
                        editField("display_name", icon: "person", text: $vm.displayName)
                        editField("e_mail", icon: "envelope", text: $vm.email, keyboard: .emailAddress)
                        editField("phone_number", icon: "phone", text: $vm.phoneNumber, keyboard: .phonePad)
                    }

                    sectionCard(title: "introduct_ion", icon: "text.quote") {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.95))
                                .frame(width: 20)
                                .padding(.top, 14)
                            TextEditor(text: $vm.bio)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(Color(white: 0.15))
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.72))
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color(white: 0.88), lineWidth: 0.8))
                        )
                    }

                    if let err = vm.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                            Text(err)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                        }
                        .padding(.horizontal, 20)
                    }

                    HStack(spacing: 12) {
                        Button { dismiss() } label: {
                            Text("can_cel")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(white: 0.35))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.45))
                                        .overlay(RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.8))
                                )
                        }

                        Button {
                            Task {
                                do {
                                    let refreshed = try await vm.save(user: user)
                                    if let refreshed = refreshed {
                                        user = refreshed
                                        dismiss()
                                    }
                                } catch {
                                    vm.errorMessage = error.localizedDescription
                                }
                            }
                        } label: {
                            ZStack {
                                if vm.isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("sa_ve")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.45, blue: 0.95),
                                            Color(red: 0.35, green: 0.6, blue: 1.0)
                                        ],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                                    .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.4), radius: 10, x: 0, y: 5)
                            )
                        }
                        .disabled(vm.isSaving)
                    }
                    .padding(.horizontal, 4)

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("edit_profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("can_cel") { dismiss() }
                    .foregroundColor(.white)
            }
        }
        .onAppear { vm.load(from: user) }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: LocalizedStringKey,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(white: 0.15))
            }
            content()
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.28))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.8)
            }
        )
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private func editField(
        _ placeholder: LocalizedStringKey,
        icon: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.95))
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(Color(white: 0.15))
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(white: 0.88), lineWidth: 0.8))
        )
    }
}
