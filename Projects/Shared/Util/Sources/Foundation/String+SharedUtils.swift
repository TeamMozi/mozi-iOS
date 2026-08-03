import Foundation

public extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }

    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    var nonEmpty: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }

    func containsIgnoringCase(_ other: String) -> Bool {
        range(of: other, options: .caseInsensitive) != nil
    }

    func hasPrefixIgnoringCase(_ prefix: String) -> Bool {
        lowercased().hasPrefix(prefix.lowercased())
    }

    var removingWhitespacesAndNewlines: String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }
}
