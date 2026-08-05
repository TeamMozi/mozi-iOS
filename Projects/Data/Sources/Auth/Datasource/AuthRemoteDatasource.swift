import CoreNetwork
import Foundation

public struct AuthRemoteDatasource: Sendable {
    private let plainClient: any NetworkClient
    private let authedClient: any NetworkClient
    private let encoder: JSONEncoder

    public init(
        plainClient: any NetworkClient,
        authedClient: any NetworkClient,
        encoder: JSONEncoder = NetworkJSONCoding.makeEncoder()
    ) {
        self.plainClient = plainClient
        self.authedClient = authedClient
        self.encoder = encoder
    }

    public func loginWithKakao(accessToken: String) async throws -> LoginResponseDTO {
        let body = try encoder.encode(KakaoLoginRequestDTO(accessToken: accessToken))
        return try await plainClient.request(AuthEndpoint.loginKakao(body))
    }

    public func loginWithApple(identityToken: String) async throws -> LoginResponseDTO {
        let body = try encoder.encode(AppleLoginRequestDTO(identityToken: identityToken))
        return try await plainClient.request(AuthEndpoint.loginApple(body))
    }

    public func loginWithDev() async throws -> LoginResponseDTO {
        let body = try encoder.encode(DevLoginRequestDTO())
        return try await plainClient.request(AuthEndpoint.loginDev(body))
    }

    public func refresh(refreshToken: String) async throws -> TokenResponseDTO {
        let body = try encoder.encode(RefreshRequestDTO(refreshToken: refreshToken))
        return try await plainClient.request(AuthEndpoint.refresh(body))
    }

    public func logout() async throws {
        try await authedClient.request(AuthEndpoint.logout)
    }
}
