import Foundation

/// 업로드 때 fastlane 이 Info.plist 로 넘긴 문구와 해시. 둘 중 하나라도 없으면 개발 빌드다.
public struct DemoBuildInfo: Equatable, Sendable {
    struct Upload: Equatable, Sendable {
        let note: String
        let commitHash: String
    }

    static let noteKey = "MoziBuildNote"
    static let commitHashKey = "MoziBuildHash"
    static let buildNumberKey = "CFBundleVersion"
    static let developmentSummary = "개발 빌드"

    public static let current = DemoBuildInfo(infoDictionary: Bundle.main.infoDictionary ?? [:])

    let buildNumber: String
    let upload: Upload?

    init(infoDictionary: [String: Any]) {
        buildNumber = infoDictionary[Self.buildNumberKey] as? String ?? ""
        let encodedNote = infoDictionary[Self.noteKey] as? String ?? ""
        let commitHash = (infoDictionary[Self.commitHashKey] as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        // 문구는 셸과 빌드 설정을 거치며 깨지지 않게 Base64 로 들어온다.
        let note = Data(base64Encoded: encodedNote).flatMap { String(data: $0, encoding: .utf8) } ?? ""

        if note.isEmpty || commitHash.isEmpty {
            upload = nil
        } else {
            upload = Upload(note: note, commitHash: commitHash)
        }
    }

    /// 첫 화면 「이번 빌드에서 바뀐 것」 칸의 글.
    public var changeSummary: String {
        upload?.note ?? Self.developmentSummary
    }

    /// 첫 화면 바닥 글. 개발 빌드에서는 없다.
    public var footer: String? {
        upload.map { "빌드 \(buildNumber) · \($0.commitHash)" }
    }
}
