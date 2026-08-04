import CoreNetwork
import Domain
import Foundation

public actor AuthTokenRefresher: TokenRefreshing {
    private let remote: AuthRemoteDatasource
    private let local: AuthLocalDatasource

    public init(remote: AuthRemoteDatasource, local: AuthLocalDatasource) {
        self.remote = remote
        self.local = local
    }

    public func refresh() async throws {
        guard let session = try await local.load() else {
            throw AuthError.unauthorized
        }

        do {
            let tokens = try await remote.refresh(refreshToken: session.refreshToken)
            try await local.save(tokens.applying(to: session))
        } catch {
            throw await mapRefreshFailure(error)
        }
    }

    private func mapRefreshFailure(_ error: Error) async -> AuthError {
        if let authError = error as? AuthError {
            if case .unauthorized = authError {
                try? await local.clear()
            }
            return authError
        }

        guard let networkError = error as? NetworkError else {
            // 알 수 없는 오류는 세션을 유지한다.
            return .unknown(message: String(describing: error))
        }

        switch networkError {
        case .unauthorized, .badRequest:
            // invalid/expired refresh 로 보고 세션 종료
            try? await local.clear()
            return .unauthorized
        case .transport:
            // 일시 네트워크 오류는 세션 유지
            return .network
        default:
            // 서버/기타 오류는 세션 유지
            return .unknown(message: String(describing: networkError))
        }
    }
}
