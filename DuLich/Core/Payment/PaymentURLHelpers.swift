import Foundation

enum PaymentText {
    static func sanitizeOrderInfo(_ text: String) -> String {
        let folded = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "vi_VN"))
        let filtered = folded.unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar) || scalar == " "
        }
        return String(String.UnicodeScalarView(filtered)).prefix(200).description
    }
}

extension URL {
    var paymentQueryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let items = components.queryItems
        else { return [:] }

        var dict: [String: String] = [:]
        for item in items {
            guard let value = item.value else { continue }
            dict[item.name] = value
        }
        return dict
    }
}
