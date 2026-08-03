import Foundation

public final class Locked<Value: Sendable>: @unchecked Sendable {
    private var value: Value
    private let lock = NSLock()

    public init(_ value: Value) {
        self.value = value
    }

    public func withLock<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }

    public func read<T>(_ body: (Value) throws -> T) rethrows -> T {
        try withLock { current in
            try body(current)
        }
    }
}
