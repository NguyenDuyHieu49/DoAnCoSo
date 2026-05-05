import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void
    var enabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.button())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(enabled ? Color.primaryBlue : Color.primaryBlue.opacity(0.5))
                .cornerRadius(14)
                .shadow(color: Color.primaryBlue.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .disabled(!enabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "Create An Account", action: {})
            PrimaryButton(title: "Disabled", action: {}, enabled: false)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
