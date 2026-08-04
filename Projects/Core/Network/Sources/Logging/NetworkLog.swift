import Foundation
import SharedLogger

enum NetworkLog {
    static func request(_ request: URLRequest) {
        let method = request.httpMethod ?? "NIL"
        let url = request.url?.absoluteString ?? "nil"
        var message = "→ \(method) \(url)"

        #if DEBUG
        if let body = request.httpBody, let bodyText = String(data: body, encoding: .utf8) {
            message += "\nBody: \(redact(bodyText))"
        }
        #endif

        Logger.shared.info(redact(message), category: .network)
    }

    static func response(
        statusCode: Int,
        url: URL?,
        data: Data,
        durationMs: Int
    ) {
        let target = url?.absoluteString ?? "nil"
        var message = "← \(statusCode) \(target) (\(durationMs)ms, \(data.count)B)"

        #if DEBUG
        if let bodyText = String(data: data, encoding: .utf8), !bodyText.isEmpty {
            message += "\nBody: \(redact(bodyText))"
        }
        #endif

        if (200...299).contains(statusCode) {
            Logger.shared.info(message, category: .network)
        } else {
            Logger.shared.warning(message, category: .network)
        }
    }

    static func error(_ error: Error, url: URL?) {
        let target = url?.absoluteString ?? "nil"
        Logger.shared.error("✕ \(target) \(error.localizedDescription)", category: .network)
    }

    static func redact(_ text: String) -> String {
        var output = text
        let patterns = [
            #"Bearer\s+[A-Za-z0-9\-._~+/]+=*"#,
            #"(accessToken|refreshToken|Authorization)"\s*:\s*"[^"]+""#,
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(output.startIndex..<output.endIndex, in: output)
                output = regex.stringByReplacingMatches(
                    in: output,
                    options: [],
                    range: range,
                    withTemplate: "[REDACTED]"
                )
            }
        }
        return output
    }
}
