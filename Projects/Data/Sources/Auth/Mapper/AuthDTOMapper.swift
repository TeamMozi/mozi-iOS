import Domain
import Foundation

enum AuthDTOMapper {
    static func storage(from response: LoginResponseDTO) -> AuthSessionStorageDTO {
        AuthSessionStorageDTO(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            isNewUser: response.isNewUser,
            profileCompleted: response.profileCompleted,
            userID: String(response.userId)
        )
    }

    /// 토큰 회전 경로. 상태 둘은 갱신 응답에 없으므로 기존 저장분에서 이어 쓴다.
    static func storage(
        from token: TokenResponseDTO,
        keeping current: AuthSessionStorageDTO
    ) -> AuthSessionStorageDTO {
        AuthSessionStorageDTO(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
            isNewUser: current.isNewUser,
            profileCompleted: current.profileCompleted,
            userID: String(token.userId)
        )
    }

    /// 로그인 직후 경로. 응답에는 식별자가 언제나 있으므로 빈 값이 나올 수 없다.
    static func domain(from response: LoginResponseDTO) -> AuthSession {
        AuthSession(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            isNewUser: response.isNewUser,
            profileCompleted: response.profileCompleted,
            userID: String(response.userId)
        )
    }

    /// 복원 경로. 식별자가 없는 저장분은 세션이 없는 것으로 본다.
    static func domain(from dto: AuthSessionStorageDTO) -> AuthSession? {
        guard let userID = dto.userID else {
            return nil
        }
        return AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            isNewUser: dto.isNewUser,
            profileCompleted: dto.profileCompleted,
            userID: userID
        )
    }

    static func storage(from session: AuthSession) -> AuthSessionStorageDTO {
        AuthSessionStorageDTO(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            isNewUser: session.isNewUser,
            profileCompleted: session.profileCompleted,
            userID: session.userID
        )
    }
}
