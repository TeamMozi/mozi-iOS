import CoreNetwork
import CoreStorage
import Domain
import Foundation

enum AuthErrorMapper {
    /// 로그인 경로. 소셜 로그인과 네트워크와 키체인 오류가 전부 여기로 온다.
    static func login(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }

        if error is KeychainError {
            return storage(error)
        }

        guard let networkError = error as? NetworkError else {
            return .unknown(message: String(describing: error))
        }

        switch networkError {
        case .transport:
            return .network
        case .unauthorized, .badRequest:
            return .loginFailed
        default:
            return .unknown(message: String(describing: networkError))
        }
    }

    /// 저장 경로. 키체인 읽기와 쓰기 실패가 여기로 온다.
    static func storage(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        return .storage(message: String(describing: error))
    }
}
