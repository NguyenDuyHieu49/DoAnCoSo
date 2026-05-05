import SwiftUI

struct InputFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var contentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFont.subtitle(size: 13))
                .foregroundColor(.subtleText)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color.inputBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.clear, lineWidth: 0)
                )
                .font(AppFont.body())
        }
    }
}

struct InputFieldView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InputFieldView(label: "Full Name", placeholder: "Enter your name", text: .constant(""))
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
