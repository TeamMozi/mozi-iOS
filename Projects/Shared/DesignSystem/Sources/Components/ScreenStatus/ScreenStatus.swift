/// 화면이 자기 State 의 `screen` 한 칸에 드는 상태. 문구는 화면 리듀서가 정해 넣는다.
public enum ScreenStatus: Equatable, Sendable {
    case idle
    case loading
    case actionFailed(message: String)
    case loadFailed(message: String)
}

extension ScreenStatus {
    var isLoading: Bool {
        self == .loading
    }

    var actionFailureMessage: String? {
        guard case let .actionFailed(message: message) = self else {
            return nil
        }
        return message
    }

    var loadFailureMessage: String? {
        guard case let .loadFailed(message: message) = self else {
            return nil
        }
        return message
    }
}
