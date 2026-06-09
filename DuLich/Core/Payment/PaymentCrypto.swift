import Foundation
import CryptoKit

enum PaymentCrypto {
    static func hmacSHA256Hex(key: String, message: String) -> String {
        let keyData = SymmetricKey(data: Data(key.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: keyData)
        return signature.map { String(format: "%02x", $0) }.joined()
    }

    static func hmacSHA512Hex(key: String, message: String) -> String {
        let keyData = SymmetricKey(data: Data(key.utf8))
        let signature = HMAC<SHA512>.authenticationCode(for: Data(message.utf8), using: keyData)
        return signature.map { String(format: "%02x", $0) }.joined()
    }
}
