import Foundation
import ThirdParty

extension Reducer {
    /// 사용자 액션·상태 변경·화면 이동·오류를 개발 빌드 콘솔에 남기는 리듀서로 감싼다.
    ///
    /// `children` 에는 이 리듀서가 Scope·ifLet 으로 품은 자식의 액션 case 이름을 넘긴다.
    /// 그 이름의 액션과 상태 필드는 자식이 직접 찍으므로 여기서 다시 찍지 않는다.
    /// 자식 상태 안의 `path` 를 이 리듀서가 바꾸면 `<자식>.path(pop N)` 으로 한 번 찍는다.
    /// ```swift
    /// Reduce(core)
    ///     .forEach(\.path, action: \.path)
    ///     .logged(as: Self.self, children: ["placeholder"])
    /// ```
    @warn_unqualified_access
    func logged(
        as featureType: Any.Type,
        children: Set<String>
    ) -> FeatureLogReducer<Self> {
        FeatureLogReducer(
            base: self,
            scene: FeatureLog.sceneName(from: featureType),
            children: children
        )
    }
}

struct FeatureLogReducer<Base: Reducer>: Reducer {
    let base: Base
    let scene: String
    let children: Set<String>

    #if DEBUG
    func _reduce(
        into state: inout Base.State,
        action: Base.Action
    ) -> Effect<Base.Action> {
        FeatureLog.emit(
            FeatureLogEvents.beforeReduce(action: action, children: children),
            scene: scene
        )
        let oldState = state
        let effects = base._reduce(into: &state, action: action)
        FeatureLog.emit(
            FeatureLogEvents.afterReduce(
                action: action,
                from: oldState,
                to: state,
                children: children
            ),
            scene: scene
        )
        return effects
    }
    #else
    func _reduce(
        into state: inout Base.State,
        action: Base.Action
    ) -> Effect<Base.Action> {
        base._reduce(into: &state, action: action)
    }
    #endif
}

// MARK: - 한 번의 리듀스가 남길 줄

enum FeatureLogEvents {
    /// 리듀스 전에 찍는 사용자 액션 줄.
    static func beforeReduce(action: Any, children: Set<String>) -> [FeatureLog.Event] {
        let parsed = FeatureLogActionParser.nameAndPayload(action)
        guard FeatureLogActionParser.shouldLogAction(parsed, children: children) else {
            return []
        }
        return [.action(name: parsed.name, payload: parsed.payload)]
    }

    /// 리듀스 뒤에 찍는 상태 변경·화면 이동·오류 줄. 필드 선언 순서, 자식 스택, 오류 순이다.
    static func afterReduce<State>(
        action: Any,
        from old: State,
        to new: State,
        children: Set<String>
    ) -> [FeatureLog.Event] {
        var events: [FeatureLog.Event] = []

        let changes = FeatureLogStateDiff.changedFields(from: old, to: new)
        for change in changes where children.contains(change.field) == false {
            if let style = FeatureLogStateDiff.navigationStyle(for: change) {
                events.append(
                    .navigation(field: change.field, from: change.from, to: change.to, style: style)
                )
            } else {
                events.append(.state(field: change.field, from: change.from, to: change.to))
            }
        }

        let stackChanges = FeatureLogStateDiff.stackChanges(from: old, to: new)
            + FeatureLogStateDiff.childStackChanges(from: old, to: new, children: children)
        for stack in stackChanges where children.contains(stack.field) == false {
            events.append(.stack(field: stack.field, style: stack.style, detail: stack.detail))
        }

        let parsed = FeatureLogActionParser.nameAndPayload(action)
        if let failure = FeatureLogActionParser.failureInfo(
            from: action,
            parsed: parsed,
            children: children
        ) {
            events.append(
                .error(
                    operation: failure.operation,
                    error: failure.error,
                    userVisible: FeatureLogStateDiff.becameUserVisible(from: changes)
                )
            )
        }

        return events
    }
}

// MARK: - 액션

enum FeatureLogActionParser {
    struct Parsed: Equatable {
        var name: String
        var payload: String?
    }

    struct FailureInfo: Equatable {
        var operation: String
        var error: String
    }

    /// 어느 층에서도 액션으로 찍지 않는 case 이름.
    /// `delegate` 는 받는 부모의 화면 이동 줄로, `path` 는 스택 줄과 쌓인 화면 자신의 줄로 남는다.
    private static let structuralActionNames: Set<String> = ["delegate", "path"]

    static func nameAndPayload(_ action: Any) -> Parsed {
        let mirror = Mirror(reflecting: action)

        if mirror.displayStyle == .enum {
            if let child = mirror.children.first {
                let name = child.label ?? String(describing: action)
                let payload = payloadSummary(from: child.value)
                return Parsed(name: name, payload: payload)
            }

            // 연관값 없는 case: 설명 문자열이 곧 case 이름이다
            return Parsed(name: String(describing: action), payload: nil)
        }

        let description = String(describing: action)
        let name = description.split(separator: "(").first.map(String.init) ?? description
        return Parsed(name: name, payload: nil)
    }

    static func shouldLogAction(_ parsed: Parsed, children: Set<String>) -> Bool {
        structuralActionNames.contains(parsed.name) == false
            && children.contains(parsed.name) == false
    }

    static func failureInfo(
        from action: Any,
        parsed: Parsed,
        children: Set<String>
    ) -> FailureInfo? {
        // 자식 액션 안의 실패(예: login(.loginResponse(.failure))) 는 자식이 찍는다
        guard shouldLogAction(parsed, children: children) else {
            return nil
        }

        guard let associatedValue = rootAssociatedValue(of: action) else {
            return nil
        }

        guard let error = rootFailureToken(from: associatedValue) else {
            return nil
        }

        return FailureInfo(
            operation: FeatureLog.operationName(fromActionName: parsed.name),
            error: error
        )
    }

    // MARK: - 페이로드

    private static func payloadSummary(from associatedValue: Any) -> String? {
        let mirror = Mirror(reflecting: associatedValue)

        if mirror.displayStyle == .tuple {
            let parts = mirror.children.compactMap { child -> String? in
                guard let label = child.label, isLabeledArgument(label) else {
                    return FeatureLog.summarizeValue(child.value)
                }
                return "\(label)=\(FeatureLog.summarizeValue(child.value))"
            }
            let joined = parts.joined(separator: ", ")
            return joined.isEmpty ? nil : joined
        }

        if mirror.displayStyle == .enum {
            if let child = mirror.children.first, let label = child.label {
                if label == "failure" || label == "success" {
                    return "result=\(label)"
                }
                return "\(label)=\(FeatureLog.summarizeValue(child.value))"
            }
            return FeatureLog.summarizeValue(associatedValue)
        }

        return FeatureLog.summarizeValue(associatedValue)
    }

    private static func isLabeledArgument(_ label: String) -> Bool {
        // Mirror 는 라벨 없는 튜플 요소를 ".0", ".1" 로 보여 준다
        label.firstIndex(where: { $0 != "." && !$0.isNumber }) != nil
    }

    // MARK: - 실패 찾기

    private static func rootAssociatedValue(of action: Any) -> Any? {
        let mirror = Mirror(reflecting: action)
        guard mirror.displayStyle == .enum else {
            return nil
        }
        return mirror.children.first?.value
    }

    /// 액션 자신의 연관값에서만 `Result.failure` 를 찾는다. 중첩 액션 안으로 내려가지 않는다.
    private static func rootFailureToken(from associatedValue: Any) -> String? {
        var value = associatedValue
        var mirror = Mirror(reflecting: value)

        if mirror.displayStyle == .optional {
            guard let child = mirror.children.first else {
                return nil
            }
            value = child.value
            mirror = Mirror(reflecting: value)
        }

        if mirror.displayStyle == .enum, let child = mirror.children.first {
            if child.label == "failure" {
                return leafErrorToken(child.value)
            }
            return nil
        }

        let description = String(describing: value)
        if description.hasPrefix("failure(") || description.hasPrefix(".failure(") {
            return failureToken(fromDescription: description) ?? "failure"
        }

        return nil
    }

    private static func leafErrorToken(_ value: Any) -> String {
        let mirror = Mirror(reflecting: value)

        if mirror.displayStyle == .enum {
            if let child = mirror.children.first {
                if let label = child.label, label.isEmpty == false {
                    return lastPathComponent(label)
                }
                return lastPathComponent(String(describing: child.value))
            }
            return lastPathComponent(String(describing: value))
        }

        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                return leafErrorToken(child.value)
            }
            return "nil"
        }

        return lastPathComponent(String(describing: value))
    }

    private static func failureToken(fromDescription description: String) -> String? {
        guard let regex = try? NSRegularExpression(
            pattern: #"failure\(([^)]+)\)"#,
            options: [.caseInsensitive]
        ) else {
            return nil
        }

        let range = NSRange(description.startIndex..<description.endIndex, in: description)
        guard let match = regex.firstMatch(in: description, options: [], range: range),
              match.numberOfRanges > 1,
              let tokenRange = Range(match.range(at: 1), in: description)
        else {
            return nil
        }

        return lastPathComponent(String(description[tokenRange]))
    }

    private static func lastPathComponent(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let last = trimmed.split(separator: ".").last {
            return String(last)
        }
        return trimmed
    }
}

// MARK: - 상태

/// 화면 스택. TCA `StackState` 는 Mirror 로 원소를 읽을 수 없어 이 프로토콜로 읽는다.
protocol FeatureLogStack {
    /// 쌓인 화면마다 case 이름. 맨 아래가 처음이다.
    var featureLogElementNames: [String] { get }
}

extension StackState: FeatureLogStack {
    var featureLogElementNames: [String] {
        map { FeatureLog.summarizeValue($0) }
    }
}

enum FeatureLogStateDiff {
    struct Change: Equatable {
        var field: String
        var from: String
        var to: String
        var isPresentation = false
    }

    struct StackChange: Equatable {
        var field: String
        var style: FeatureLog.NavigationStyle
        var detail: String
    }

    private static let failureScreenCases: Set<String> = ["actionFailed", "loadFailed"]

    /// `@ObservableState` 의 저장 라벨을 필드 이름으로 바꾼다.
    ///
    /// - `_isLoading` → `isLoading`
    /// - `_$observationRegistrar` 같은 `_$` 관리 필드 → 무시 (`nil`)
    static func normalizedFieldLabel(_ label: String) -> String? {
        if label.hasPrefix("_$") {
            return nil
        }
        if label.hasPrefix("_"), label.count > 1 {
            return String(label.dropFirst())
        }
        return label
    }

    /// 최상위 필드 중 요약 값이 바뀐 것. 화면 스택 필드는 `stackChanges` 가 맡는다.
    static func changedFields<State>(from old: State, to new: State) -> [Change] {
        let oldFields = fields(of: old)
        let newFields = Dictionary(fields(of: new).map { ($0.name, $0) }) { first, _ in first }

        var changes: [Change] = []
        for oldField in oldFields {
            guard let newField = newFields[oldField.name] else {
                continue
            }
            if isStack(oldField.value) || isStack(newField.value) {
                continue
            }

            let isPresentation = oldField.isPresentation || newField.isPresentation
            let fromSummary = summary(of: oldField.value, isPresentation: isPresentation)
            let toSummary = summary(of: newField.value, isPresentation: isPresentation)
            if fromSummary == toSummary {
                continue
            }

            changes.append(
                Change(
                    field: oldField.name,
                    from: fromSummary,
                    to: toSummary,
                    isPresentation: isPresentation
                )
            )
        }
        return changes
    }

    /// 최상위 화면 스택 필드의 칸 수 변화.
    static func stackChanges<State>(from old: State, to new: State) -> [StackChange] {
        let newFields = Dictionary(fields(of: new).map { ($0.name, $0) }) { first, _ in first }

        var changes: [StackChange] = []
        for oldField in fields(of: old) {
            guard let oldStack = oldField.value as? any FeatureLogStack,
                  let newStack = newFields[oldField.name]?.value as? any FeatureLogStack,
                  let change = stackChange(
                      field: oldField.name,
                      from: oldStack.featureLogElementNames,
                      to: newStack.featureLogElementNames
                  )
            else {
                continue
            }
            changes.append(change)
        }
        return changes
    }

    /// `children` 으로 받은 자식 상태 안의 화면 스택 칸 수 변화. 필드 이름은 `<자식>.<스택>` 이다.
    static func childStackChanges<State>(
        from old: State,
        to new: State,
        children: Set<String>
    ) -> [StackChange] {
        guard children.isEmpty == false else {
            return []
        }
        let newFields = Dictionary(fields(of: new).map { ($0.name, $0) }) { first, _ in first }

        var changes: [StackChange] = []
        for oldField in fields(of: old) where children.contains(oldField.name) {
            // 자식 상태가 옵셔널이면 한 겹 푼다
            guard let oldChild = oldField.value.flatMap(optionalPayload),
                  let newChild = newFields[oldField.name]?.value.flatMap(optionalPayload)
            else {
                continue
            }
            for change in stackChanges(from: oldChild, to: newChild) {
                changes.append(
                    StackChange(
                        field: "\(oldField.name).\(change.field)",
                        style: change.style,
                        detail: change.detail
                    )
                )
            }
        }
        return changes
    }

    /// 한 칸이면 그 화면의 case 이름, 여러 칸이면 칸 수를 남긴다.
    static func stackChange(field: String, from old: [String], to new: [String]) -> StackChange? {
        let delta = new.count - old.count
        if delta == 1, let top = new.last {
            return StackChange(field: field, style: .push, detail: top)
        }
        if delta == -1, let top = old.last {
            return StackChange(field: field, style: .pop, detail: top)
        }
        if delta > 1 {
            return StackChange(field: field, style: .push, detail: "\(delta)")
        }
        if delta < -1 {
            return StackChange(field: field, style: .pop, detail: "\(-delta)")
        }
        return nil
    }

    static func navigationStyle(for change: Change) -> FeatureLog.NavigationStyle? {
        switch change.field {
        case "phase":
            return .phase
        case "selectedTab":
            return .tab
        case "pendingDeepLink":
            return .deepLink
        default:
            break
        }

        guard change.isPresentation else {
            return nil
        }
        return change.to == "nil" ? .dismiss : .present
    }

    /// 같은 리듀스에서 오류가 화면에 떴는지. `screen` 이 실패 case 로 바뀌었거나 `errorMessage` 가 nil 에서 값이 됐다.
    static func becameUserVisible(from changes: [Change]) -> Bool {
        changes.contains { change in
            switch change.field {
            case "screen":
                return failureScreenCases.contains(change.to)
            case "errorMessage":
                return change.from == "nil" && change.to != "nil"
            default:
                return false
            }
        }
    }

    // MARK: - 비공개

    private struct Field {
        var name: String
        var value: Any?
        var isPresentation: Bool
    }

    private static func fields(of value: Any) -> [Field] {
        var result: [Field] = []
        var seen = Set<String>()
        let mirror = Mirror(reflecting: value)

        var children = Array(mirror.children)
        // 일부 래퍼는 superclass mirror 뒤에 멤버를 둔다
        if let superclassMirror = mirror.superclassMirror {
            children += Array(superclassMirror.children)
        }

        for child in children {
            guard let label = child.label,
                  let name = normalizedFieldLabel(label),
                  seen.insert(name).inserted
            else {
                continue
            }
            if isPresentationState(child.value) {
                result.append(
                    Field(name: name, value: presentationWrappedValue(from: child.value), isPresentation: true)
                )
            } else {
                result.append(Field(name: name, value: child.value, isPresentation: false))
            }
        }
        return result
    }

    private static func isStack(_ value: Any?) -> Bool {
        guard let value else {
            return false
        }
        return value is any FeatureLogStack
    }

    private static func summary(of value: Any?, isPresentation: Bool) -> String {
        let summarized = FeatureLog.summarizeValue(value)
        // 띄운 화면은 안을 찍지 않고 presented 로만 남긴다
        if isPresentation {
            return summarized == "nil" ? "nil" : "presented"
        }
        return summarized
    }

    /// TCA `PresentationState`(`@Presents`) 인지 타입 이름으로 본다.
    static func isPresentationState(_ value: Any) -> Bool {
        let typeName = String(describing: type(of: value))
        return typeName.hasPrefix("PresentationState<") || typeName == "PresentationState"
    }

    /// `PresentationState` 를 띄운 상태 값 또는 nil 로 푼다.
    static func presentationWrappedValue(from value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)

        if let child = mirror.children.first(where: { $0.label == "wrappedValue" }) {
            return optionalPayload(from: child.value)
        }

        // TCA PresentationState 는 optional 상태를 private `storage` 에 둔다
        if let storageChild = mirror.children.first(where: { $0.label == "storage" }) {
            let storageMirror = Mirror(reflecting: storageChild.value)
            if let stateChild = storageMirror.children.first(where: { $0.label == "state" }) {
                return optionalPayload(from: stateChild.value)
            }
            if let first = storageMirror.children.first {
                return optionalPayload(from: first.value)
            }
        }

        // summarizeValue 는 구조체를 타입 이름으로 요약하므로 nil 판정에 쓸 수 없다. 자식 유무로 본다
        return mirror.children.isEmpty ? nil : value
    }

    private static func optionalPayload(from value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            return mirror.children.first?.value
        }
        return value
    }
}
