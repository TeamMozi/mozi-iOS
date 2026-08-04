import CoreNetwork
import Foundation

actor StubTokenProvider: TokenProviding {
    var token: String?

    init(token: String? = "access-token") {
        self.token = token
    }

    func accessToken() async throws -> String? {
        token
    }
}

actor StubTokenRefresher: TokenRefreshing {
    private(set) var refreshCount = 0
    private var error: Error?

    func setError(_ error: Error?) {
        self.error = error
    }

    func refresh() async throws {
        refreshCount += 1
        if let error {
            throw error
        }
    }
}
