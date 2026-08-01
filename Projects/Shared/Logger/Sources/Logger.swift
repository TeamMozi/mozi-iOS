import Foundation
import OSLog

public final class Logger: @unchecked Sendable {
    public static let shared = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "unknown.bundle"
    )

    private let subsystem: String
    private let lock = NSLock()
    private var loggers: [LogCategory: os.Logger] = [:]

    init(subsystem: String) {
        self.subsystem = subsystem
    }

    public func debug(
        _ message: @autoclosure () -> String,
        category: LogCategory = .general,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message(),
            level: .debug,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        _ message: @autoclosure () -> String,
        category: LogCategory = .general,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message(),
            level: .info,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        _ message: @autoclosure () -> String,
        category: LogCategory = .general,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message(),
            level: .warning,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }

    public func error(
        _ message: @autoclosure () -> String,
        category: LogCategory = .general,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message(),
            level: .error,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }

    private func log(
        _ message: String,
        level: LogLevel,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        #if DEBUG
        let fileName = file.split(separator: "/").last.map(String.init) ?? file
        let composed = "[\(category.rawValue)] [\(fileName):\(line)] \(function) - \(message)"
        let logger = osLogger(for: category)
        logger.log(level: level.osLogType, "\(composed, privacy: .public)")
        #endif
    }

    private func osLogger(for category: LogCategory) -> os.Logger {
        lock.lock()
        defer { lock.unlock() }

        if let existing = loggers[category] {
            return existing
        }

        let created = os.Logger(subsystem: subsystem, category: category.rawValue)
        loggers[category] = created
        return created
    }
}
