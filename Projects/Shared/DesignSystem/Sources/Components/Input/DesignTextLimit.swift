import Foundation

/// 최대보다 긴 값이 넘어왔을 때 칸이 하는 일.
enum DesignTextOverflow: Equatable, Sendable {
    /// 한 줄 칸. 받자마자 최대까지 잘라 쓰는 쪽 값도 바꾼다.
    case truncate
    /// 여러 줄·캡션 칸. 값을 그대로 두고 지우기만 받는다.
    case keep
}

/// 편집 한 번에 대한 판정.
enum DesignTextEditDecision: Equatable, Sendable {
    case accept
    case reject
    /// 넣으려던 글 대신 이 글을 넣는다. 붙여넣은 긴 글의 뒷부분을 자른 것이다.
    case replace(with: String)
}

/// 글자 수 규칙. 보이는 글자 하나(`Character`)를 1자로 센다.
/// 조합 중이면 `decide` 는 판정하지 않고 받으며, 넘친 글자는 조합이 끝난 뒤 `settle` 이 자른다.
struct DesignTextLimit: Equatable, Sendable {
    let maxLength: Int
    let overflow: DesignTextOverflow

    /// UIKit `shouldChange…` 한 번을 판정한다. `range` 는 `current` 의 UTF-16 범위다.
    /// 최대 안이면 받고, 넘치면 지우기만 받는다. 넘치는 붙여넣기는 남은 자리만큼 앞부분으로 바꾼다.
    func decide(current: String, range: NSRange, replacement: String, isComposing: Bool) -> DesignTextEditDecision {
        if isComposing {
            return .accept
        }
        let source = current as NSString
        guard range.location != NSNotFound, NSMaxRange(range) <= source.length else {
            return .accept
        }
        let result = source.replacingCharacters(in: range, with: replacement)
        if result.count <= maxLength || replacement.isEmpty {
            return .accept
        }
        let room = maxLength - source.replacingCharacters(in: range, with: "").count
        guard room > 0 else {
            return .reject
        }
        return .replace(with: String(replacement.prefix(room)))
    }

    /// 조합이 끝난 뒤의 값을 정한다. `previous` 는 조합 전에 받아 둔 값이다.
    /// 앞뒤로 `previous` 와 같은 글자는 두고, 새로 들어온 가운데 글자에서 넘친 만큼 뒤를 자른다.
    /// `previous` 보다 늘지 않았으면(긴 값에서 지우기) 그대로 둔다.
    func settle(_ text: String, previous: String) -> String {
        let limit = max(maxLength, previous.count)
        guard text.count > limit else {
            return text
        }
        let old = Array(previous)
        let new = Array(text)
        var head = 0
        while head < old.count, head < new.count, old[head] == new[head] {
            head += 1
        }
        var tail = 0
        while tail < old.count - head, tail < new.count - head,
              old[old.count - 1 - tail] == new[new.count - 1 - tail] {
            tail += 1
        }
        let inserted = new[head..<(new.count - tail)]
        let kept = inserted.dropLast(min(new.count - limit, inserted.count))
        return String(new[..<head]) + String(kept) + String(new[(new.count - tail)...])
    }

    /// 쓰는 쪽이 넘긴 값을 칸에 보일 값으로 바꾼다.
    func incoming(_ value: String) -> String {
        switch overflow {
        case .truncate:
            String(value.prefix(maxLength))
        case .keep:
            value
        }
    }

    /// 칸 안 오른쪽 아래 글자 수. 「4/50」, 긴 값은 「55/50」.
    func counterText(for text: String) -> String {
        "\(text.count)/\(maxLength)"
    }
}
