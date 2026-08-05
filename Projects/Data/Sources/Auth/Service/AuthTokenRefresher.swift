import CoreNetwork
import CoreStorage
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
        let session: AuthSession
        do {
            guard let loaded = try await local.load() else {
                throw AuthError.unauthorized
            }
            session = loaded
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.storage(message: String(describing: error))
        }

        do {
            let tokens = try await remote.refresh(refreshToken: session.refreshToken)
            do {
                try await local.save(tokens.applying(to: session))
            } catch {
                throw AuthError.storage(message: String(describing: error))
            }
        } catch let error as AuthError {
            throw error
        } catch {
            throw await mapRefreshFailure(error)
        }
    }

    private func mapRefreshFailure(_ error: Error) async -> AuthError {
        guard let networkError = error as? NetworkError else {
            // 알 수 없는 오류는 세션을 유지한다.
            return .unknown(message: String(describing: error))
        }

        switch networkError {
        case .unauthorized:
            // invalid/expired refresh 로 보고 세션 종료
            // clear 실패는 삼키고 unauthorized UX를 유지한다.
            try? await local.clear()
            return .unauthorized
        case .transport:
            // 일시 네트워크 오류는 세션 유지
            return .network
        case .badRequest:
            // 형식/검증 오류는 세션 유지
            return .unknown(message: String(describing: networkError))
        default:
            // 서버/기타 오류는 세션 유지
            return .unknown(message: String(describing: networkError))
        }
    }
}
