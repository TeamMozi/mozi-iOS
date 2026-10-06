import Foundation
import SharedLogger

enum FeatureLog {
    enum NavigationStyle: String, Equatable, Sendable {
        case phase
        case tab
        case present
        case dismiss
        case deepLink
        case push
        case pop
    }

    /// 리듀스 한 번이 남기는 로그 한 줄.
    enum Event: Equatable {
        case action(name: String, payload: String?)
        case state(field: String, from: String, to: String)
        case navigation(field: String, from: String, to: String, style: NavigationStyle)
        /// 쌓인 화면 수의 변화. `detail` 은 한 칸이면 그 화면의 case 이름, 여러 칸이면 칸 수다.
        case stack(field: String, style: NavigationStyle, detail: String)
        case error(operation: String, error: String, userVisible: Bool)
    }

    // MARK: - 출력

    static func emit(_ events: [Event], scene: String) {
        for event in events {
            let line = message(for: event, scene: scene)
            switch event {
            case .action, .state:
                Logger.shared.debug(line, category: .feature, includeCallSite: false)
            case .navigation, .stack:
                Logger.shared.info(line, category: .feature, includeCallSite: false)
            case let .error(_, _, userVisible):
                if userVisible {
                    Logger.shared.error(line, category: .feature, includeCallSite: false)
                } else {
                    Logger.shared.warning(line, category: .feature, includeCallSite: false)
                }
            }
        }
    }

    // MARK: - 메시지 포맷

    static func message(for event: Event, scene: String) -> String {
        switch event {
        case let .action(name, payload):
            return actionMessage(scene: scene, name: name, payload: payload)
        case let .state(field, from, to):
            return stateMessage(scene: scene, field: field, from: from, to: to)
        case let .navigation(field, from, to, _):
            return navigationMessage(scene: scene, field: field, from: from, to: to)
        case let .stack(field, style, detail):
            return stackMessage(scene: scene, field: field, style: style, detail: detail)
        case let .error(operation, error, userVisible):
            return errorMessage(scene: scene, operation: operation, error: error, userVisible: userVisible)
        }
    }

    static func actionMessage(
        scene: String,
        name: String,
        payload: String? = nil
    ) -> String {
        let detail: String
        if let payload, payload.isEmpty == false {
            detail = "\(name)(\(redact(payload)))"
        } else {
            detail = name
        }
        return "[Feature] [\(scene)] 사용자 액션: \(detail)"
    }

    static func stateMessage(
        scene: String,
        field: String,
        from: String,
        to: String
    ) -> String {
        "[Feature] [\(scene)] 상태 변경: \(field)(\(redact(from)) → \(redact(to)))"
    }

    static func navigationMessage(
        scene: String,
        field: String,
        from: String,
        to: String
    ) -> String {
        "[Feature] [\(scene)] 화면 이동: \(field)(\(redact(from)) → \(redact(to)))"
    }

    static func stackMessage(
        scene: String,
        field: String,
        style: NavigationStyle,
        detail: String
    ) -> String {
        "[Feature] [\(scene)] 화면 이동: \(field)(\(style.rawValue) \(detail))"
    }

    static func errorMessage(
        scene: String,
        operation: String,
        error: String,
        userVisible: Bool
    ) -> String {
        "[Feature] [\(scene)] 오류: \(operation)(\(redact(error)), userVisible=\(userVisible))"
    }

    // MARK: - 헬퍼

    static func sceneName(from type: Any.Type) -> String {
        sceneName(from: String(describing: type))
    }

    static func sceneName(from typeName: String) -> String {
        if typeName.hasSuffix("Feature") {
            let trimmed = String(typeName.dropLast("Feature".count))
            return trimmed.isEmpty ? typeName : trimmed
        }
        return typeName
    }

    static func operationName(fromActionName actionName: String) -> String {
        if actionName.hasSuffix("Response") {
            return String(actionName.dropLast("Response".count))
        }
        return actionName
    }

    static func summarizeValue(_ value: Any?) -> String {
        guard let value else {
            return "nil"
        }

        if value is NSNull {
            return "nil"
        }

        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                return summarizeValue(child.value)
            }
            return "nil"
        }

        switch mirror.displayStyle {
        case .enum:
            // enum 은 case 이름만 남긴다 (예: main, actionFailed). 연관값은 찍지 않는다
            return enumCaseName(from: value, mirror: mirror)
        case .collection, .set, .dictionary:
            return "\(mirror.children.count) items"
        case .struct, .class:
            // 구조체·클래스는 안을 찍지 않고 타입 이름만 남긴다
            return String(describing: type(of: value))
        default:
            break
        }

        if let string = value as? String {
            return redact(FeatureLogRedaction.truncate(string))
        }

        if let bool = value as? Bool {
            return bool ? "true" : "false"
        }

        let description = String(describing: value)
        if description == "nil" {
            return "nil"
        }

        return redact(FeatureLogRedaction.truncate(description))
    }

    /// enum case 라벨만 꺼낸다. 연관값이 있어도 `main` 처럼 이름만 남긴다.
    private static func enumCaseName(from value: Any, mirror: Mirror) -> String {
        if let label = mirror.children.first?.label, !label.isEmpty {
            return label
        }

        // 연관값 없는 case 는 Mirror children 이 비어 있다. 설명 문자열에서 앞의 점과 타입 접두를 뗀다
        var description = String(describing: value)
        if description.hasPrefix(".") {
            description.removeFirst()
        }
        if let lastDot = description.lastIndex(of: ".") {
            let candidate = description[description.index(after: lastDot)...]
            if candidate.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                description = String(candidate)
            }
        }
        if let paren = description.firstIndex(of: "(") {
            description = String(description[..<paren])
        }
        return description.isEmpty ? "unknown" : description
    }

    static func redact(_ text: String) -> String {
        FeatureLogRedaction.redact(text)
    }
}

// MARK: - 가림

enum FeatureLogRedaction {
    private static let maxSummaryLength = 120

    static func redact(_ text: String) -> String {
        var output = text
        output = redactBearerTokens(in: output)
        output = redactJSONTokenFields(in: output)
        output = redactFormTokenFields(in: output)
        output = redactAuthorizationKeyValue(in: output)
        return output
    }

    static func truncate(_ text: String) -> String {
        guard text.count > maxSummaryLength else {
            return text
        }
        let endIndex = text.index(text.startIndex, offsetBy: maxSummaryLength)
        return String(text[..<endIndex]) + "…"
    }

    private static func redactBearerTokens(in text: String) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: #"Bearer\s+[A-Za-z0-9\-._~+/]+=*"#,
            options: [.caseInsensitive]
        ) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(
            in: text,
            options: [],
            range: range,
            withTemplate: "Bearer [REDACTED]"
        )
    }

    private static func redactJSONTokenFields(in text: String) -> String {
        let keys = tokenKeys.joined(separator: "|")
        let pattern = "\"(\(keys))\"\\s*:\\s*\"[^\"]*\""
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive]
        ) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(
            in: text,
            options: [],
            range: range,
            withTemplate: #""$1" : "[REDACTED]""#
        )
    }

    private static func redactFormTokenFields(in text: String) -> String {
        let keys = tokenKeys.joined(separator: "|")
        var output = text

        let quotedPattern = "(?i)\\b(\(keys))=\"[^\"&\\s]*\""
        if let regex = try? NSRegularExpression(pattern: quotedPattern) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regex.stringByReplacingMatches(
                in: output,
                options: [],
                range: range,
                withTemplate: #"$1=[REDACTED]"#
            )
        }

        let barePattern = "(?i)\\b(\(keys))=([^&\\s]+)"
        if let regex = try? NSRegularExpression(pattern: barePattern) {
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            output = regex.stringByReplacingMatches(
                in: output,
                options: [],
                range: range,
                withTemplate: #"$1=[REDACTED]"#
            )
        }

        return output
    }

    private static func redactAuthorizationKeyValue(in text: String) -> String {
        let pattern = #"(?i)\bAuthorization\s*[:=]\s*(?:Bearer\s+)?([^\s,;]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(
            in: text,
            options: [],
            range: range,
            withTemplate: "Authorization=[REDACTED]"
        )
    }

    private static let tokenKeys = [
        "accessToken",
        "refreshToken",
        "identityToken",
        "Authorization",
        "access_token",
        "refresh_token",
        "id_token",
        "identity_token"
    ]
}
