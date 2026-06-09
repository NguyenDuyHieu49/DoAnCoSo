import AuthenticationServices
import UIKit

@MainActor
final class PaymentCheckoutCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = PaymentCheckoutCoordinator()

    private var authSession: ASWebAuthenticationSession?
    private var pendingContinuation: CheckedContinuation<PaymentCheckoutResult, Error>?
    private var pendingMethod: PaymentMethod?

    private override init() {
        super.init()
    }

    func startWebCheckout(
        url: URL,
        callbackScheme: String,
        method: PaymentMethod
    ) async throws -> PaymentCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            pendingContinuation = continuation
            pendingMethod = method

            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackScheme
            ) { [weak self] callbackURL, error in
                Task { @MainActor in
                    self?.finishWebSession(callbackURL: callbackURL, error: error)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            authSession = session
            session.start()
        }
    }

    func waitForReturn(method: PaymentMethod, timeout: TimeInterval = 300) async throws -> PaymentCheckoutResult {
        try await withCheckedThrowingContinuation { continuation in
            pendingContinuation = continuation
            pendingMethod = method

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                guard self.pendingContinuation != nil, self.pendingMethod == method else { return }
                self.resumeFailure(PaymentError.cancelled)
            }
        }
    }

    func handleReturnURL(_ url: URL) -> Bool {
        guard pendingContinuation != nil else { return false }
        guard url.scheme == PaymentConfig.returnScheme else { return false }
        guard let host = url.host, host == "payment" else { return false }

        let pathMethod = url.pathComponents.dropFirst().first
        let method: PaymentMethod?
        switch pathMethod {
        case "momo": method = .momo
        case "vnpay": method = .vnpay
        default: method = pendingMethod
        }

        guard let resolvedMethod = method else { return false }

        do {
            let result: PaymentCheckoutResult
            switch resolvedMethod {
            case .momo:
                result = try MoMoGateway.shared.parseReturnURL(url)
            case .vnpay:
                result = try VNPayGateway.shared.parseReturnURL(url)
            default:
                return false
            }
            resumeSuccess(result)
        } catch {
            resumeFailure(error)
        }
        return true
    }

    func cancelPendingCheckout() {
        authSession?.cancel()
        authSession = nil
        resumeFailure(PaymentError.cancelled)
    }

    private func finishWebSession(callbackURL: URL?, error: Error?) {
        authSession = nil

        if let error = error as? ASWebAuthenticationSessionError,
           error.code == .canceledLogin {
            resumeFailure(PaymentError.cancelled)
            return
        }

        if let error {
            resumeFailure(error)
            return
        }

        guard let callbackURL else {
            resumeFailure(PaymentError.processingFailed)
            return
        }

        _ = handleReturnURL(callbackURL)
    }

    private func resumeSuccess(_ result: PaymentCheckoutResult) {
        pendingContinuation?.resume(returning: result)
        clearPending()
    }

    private func resumeFailure(_ error: Error) {
        pendingContinuation?.resume(throwing: error)
        clearPending()
    }

    private func clearPending() {
        pendingContinuation = nil
        pendingMethod = nil
        authSession = nil
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap(\.windows).first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}
