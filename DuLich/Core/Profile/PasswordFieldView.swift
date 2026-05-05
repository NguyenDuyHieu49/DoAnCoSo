import SwiftUI

struct PasswordFieldView: View {
    let label: String
    let placeholder: String
    @Binding var password: String
    @State private var isSecure: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFont.subtitle(size: 13))
                .foregroundColor(.subtleText)

            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $password)
                    } else {
                        TextField(placeholder, text: $password)
                    }
                }
                .font(AppFont.body())
                .padding(.vertical, 14)
                .padding(.leading, 16)

                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.placeholder)
                        .padding(.trailing, 16)
                }
            }
            .background(Color.inputBackground)
            .cornerRadius(12)
        }
    }
}

struct PasswordFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordFieldView(label: "Password", placeholder: "Enter your password", password: .constant(""))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
