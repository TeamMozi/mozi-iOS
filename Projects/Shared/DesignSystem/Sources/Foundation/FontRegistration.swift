import CoreText
import Foundation

public enum DesignSystemFontRegistration {
    private static let lock = NSLock()
    // `lock` 으로 보호한다. Swift 6 가변 static 상태용 명시적 escape hatch.
    nonisolated(unsafe) private static var didRegister = false

    private static let fileNames = [
        "Pretendard-Regular",
        "Pretendard-Medium",
        "Pretendard-SemiBold",
        "Pretendard-Bold",
    ]

    @discardableResult
    public static func registerIfNeeded() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        if didRegister {
            return true
        }

        var success = true
        for fileName in fileNames {
            success = registerFont(named: fileName) && success
        }

        didRegister = success
        return success
    }

    private static func registerFont(named fileName: String) -> Bool {
        let extensions = ["otf", "ttf"]
        let bundle = resourceBundle

        guard
            let url = extensions
                .compactMap({ bundle.url(forResource: fileName, withExtension: $0) })
                .first
        else {
            return false
        }

        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            return true
        }

        guard let cfError = error?.takeRetainedValue() else {
            return false
        }

        let nsError = cfError as Error as NSError
        // 프로세스에 이미 등록된 폰트면 재시도/다중 진입 bootstrap 을 허용한다.
        return nsError.domain == (kCTFontManagerErrorDomain as String)
            && (
                nsError.code == CTFontManagerError.alreadyRegistered.rawValue
                    || nsError.code == CTFontManagerError.duplicatedName.rawValue
            )
    }

    private static var resourceBundle: Bundle {
        SharedDesignSystemResources.bundle
    }
}
