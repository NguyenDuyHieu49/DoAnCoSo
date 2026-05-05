import SwiftUI

enum SocialProvider {
    case google, apple, facebook

    var imageName: String {
        switch self {
        case .google: return "googlelogo" // placeholder asset name
        case .apple: return "applelogo"
        case .facebook: return "facebook_logo" // placeholder asset name
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .google: return "Sign in with Google"
        case .apple: return "Sign in with Apple"
        case .facebook: return "Sign in with Facebook"
        }
    }
}

struct SocialSignInButton: View {
    let provider: SocialProvider
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if provider == .apple {
                    Image(systemName: provider.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                } else {
                    Image(provider.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
            .frame(width: 56, height: 56)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.cardShadow, radius: 6, x: 0, y: 4)
        }
        .accessibilityLabel(provider.accessibilityLabel)
    }
}

struct SocialSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 12) {
            SocialSignInButton(provider: .google, action: {})
            SocialSignInButton(provider: .apple, action: {})
            SocialSignInButton(provider: .facebook, action: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
