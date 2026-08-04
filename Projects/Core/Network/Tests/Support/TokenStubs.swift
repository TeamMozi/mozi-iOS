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
    private var delayNanoseconds: UInt64 = 0

    func setError(_ error: Error?) {
        self.error = error
    }

    func setDelayNanoseconds(_ value: UInt64) {
        delayNanoseconds = value
    }

    func refresh() async throws {
        refreshCount += 1
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        if let error {
            throw error
        }
    }
}
