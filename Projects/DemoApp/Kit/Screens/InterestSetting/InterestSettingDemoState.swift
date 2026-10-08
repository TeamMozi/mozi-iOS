import Domain
import Feature
import Foundation
import SharedDesignSystem

/// 카테고리 설정 화면 데모 상태 여섯.
public enum InterestSettingDemoState: String, CaseIterable, Hashable, Sendable {
    case loading
    case idle
    case selected
    case saving
    case loadFailed
    case saveFailed

    /// 프로필 화면이 넘겼다고 치는 입력값.
    static let draft = OnboardingDraft(
        nickname: "수연",
        birthDate: Date(timeIntervalSince1970: 946_684_800),
        gender: .female,
        introduction: nil,
        profileImage: .keep,
        interestIDs: []
    )

    /// 시안 `1517:81670` 에서 고른 세 칸.
    static let selectedNames = ["자기 계발", "여행/나들이", "푸드/드링크"]

    static var selectedIDs: [String] {
        InterestClient.previewInterests
            .filter { selectedNames.contains($0.name) }
            .map(\.id)
    }

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .loading: "받는 중"
        case .idle: "기본"
        case .selected: "고른 상태"
        case .saving: "저장 중"
        case .loadFailed: "받기 실패"
        case .saveFailed: "저장 실패"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .loading: "받는 중"
        case .idle: "기본"
        case .selected: "고름"
        case .saving: "저장 중"
        case .loadFailed: "받기 실패"
        case .saveFailed: "저장 실패"
        }
    }

    /// 이 상태로 시작하는 카테고리 화면 상태. 저장 중·저장 실패는 목록을 받은 채로 시작한다.
    public var interestState: InterestSettingFeature.State {
        switch self {
        case .loading, .idle, .loadFailed:
            InterestSettingFeature.State(draft: Self.draft)
        case .selected:
            InterestSettingFeature.State(draft: Self.draft, selectedIDs: Self.selectedIDs)
        case .saving:
            InterestSettingFeature.State(
                draft: Self.draft,
                interests: InterestClient.previewInterests,
                selectedIDs: Self.selectedIDs,
                isSaving: true,
                screen: .loading
            )
        case .saveFailed:
            InterestSettingFeature.State(
                draft: Self.draft,
                interests: InterestClient.previewInterests,
                selectedIDs: Self.selectedIDs,
                screen: .actionFailed(message: FeatureErrorMessage.message(for: UserError.network))
            )
        }
    }
}
