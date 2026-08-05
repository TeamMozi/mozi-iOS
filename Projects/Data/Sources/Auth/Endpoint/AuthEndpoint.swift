import CoreNetwork
import Foundation

enum AuthEndpoint: APIEndpoint {
    case loginKakao(Data)
    case loginApple(Data)
    case loginDev(Data)
    case refresh(Data)
    case logout

    var path: String {
        switch self {
        case .loginKakao:
            return "/api/auth/login/kakao"
        case .loginApple:
            return "/api/auth/login/apple"
        case .loginDev:
            return "/api/auth/login/dev"
        case .refresh:
            return "/api/auth/refresh"
        case .logout:
            return "/api/auth/logout"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case let .loginKakao(body),
             let .loginApple(body),
             let .loginDev(body),
             let .refresh(body):
            return body
        case .logout:
            return nil
        }
    }
}
