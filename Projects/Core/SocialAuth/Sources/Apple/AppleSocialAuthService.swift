import AuthenticationServices
import Foundation
import UIKit

/// Sign in with Apple 로 identity token 을 반환한다.
@MainActor
final class AppleSocialAuthService: NSObject, SocialAuthService {
    private var continuation: CheckedContinuation<String, Error>?
    private var anchor: ASPresentationAnchor?

    override init() {
        super.init()
    }

    nonisolated func login() async throws -> String {
        try await loginOnMainActor()
    }

    private func loginOnMainActor() async throws -> String {
        guard continuation == nil else {
            throw SocialAuthError.cancelled
        }
        guard let anchor = Self.resolvePresentationAnchor() else {
            throw SocialAuthError.failed
        }
        self.anchor = anchor

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    private func finish(_ result: Result<String, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        self.anchor = nil

        switch result {
        case let .success(token):
            continuation.resume(returning: token)
        case let .failure(error):
            continuation.resume(throwing: error)
        }
    }

    private static func resolvePresentationAnchor() -> ASPresentationAnchor? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let keyWindow = scenes.flatMap(\.windows).first(where: \.isKeyWindow) {
            return keyWindow
        }
        if let firstWindow = scenes.flatMap(\.windows).first {
            return firstWindow
        }
        return scenes.first.map { ASPresentationAnchor(windowScene: $0) }
    }

    private func currentAnchor() -> ASPresentationAnchor {
        guard let anchor else {
            preconditionFailure("performRequests 전에 anchor 를 정한다")
        }
        return anchor
    }
}

extension AppleSocialAuthService: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                self.finish(.failure(SocialAuthError.failed))
                return
            }

            guard let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8),
                  identityToken.isEmpty == false else {
                self.finish(.failure(SocialAuthError.failed))
                return
            }

            self.finish(.success(identityToken))
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                self.finish(.failure(SocialAuthError.cancelled))
                return
            }
            self.finish(.failure(SocialAuthError.failed))
        }
    }
}

extension AppleSocialAuthService: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        if Thread.isMainThread {
            return MainActor.assumeIsolated {
                self.currentAnchor()
            }
        }
        return DispatchQueue.main.sync {
            MainActor.assumeIsolated {
                self.currentAnchor()
            }
        }
    }
}
