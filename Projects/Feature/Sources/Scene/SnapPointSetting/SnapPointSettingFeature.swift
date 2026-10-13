import Domain
import Foundation
import SharedDesignSystem
import ThirdParty

/// 스냅 포인트 설정. 모임장만 연다. 목록·추천 스냅 포인트·도움말 덮개·편집 시트가 있다.
/// 순서는 추가한 순서다. 종료된 모임에서는 보기만 한다.
@Reducer
public struct SnapPointSettingFeature {
    /// 편집 시트 입력. `snapPointID` 가 없으면 새로 더한다.
    public struct Editor: Equatable, Sendable {
        public var snapPointID: String?
        public var name: String
        public var notificationMessage: String

        public init(snapPointID: String? = nil, name: String = "", notificationMessage: String = "") {
            self.snapPointID = snapPointID
            self.name = name
            self.notificationMessage = notificationMessage
        }

        /// 「완료」. 이름이 비었거나 알림 메시지가 50자를 넘으면 못 누른다. 알림 메시지는 비어도 된다.
        public var canSave: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && notificationMessage.count <= SnapPointLimit.notificationMessageMaxLength
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var meetingID: String
        /// 다른 화면에서 종료하면 흐름이 맞춰 넣는다
        public var isEnded: Bool
        public var snapPoints: [SnapPoint] = []
        public var isHelpPresented = false
        public var editor: Editor?
        public var isRequesting = false
        public var hasLoaded = false
        public var screen: ScreenStatus = .idle

        public init(meetingID: String, isEnded: Bool) {
            self.meetingID = meetingID
            self.isEnded = isEnded
        }

        /// 「직접 추가 +」 와 추천 카드. 10개가 차거나 종료되면 못 누른다.
        public var canAdd: Bool {
            hasLoaded && !isEnded && !isRequesting && snapPoints.count < SnapPointLimit.maxCount
        }

        /// 카드 `•••` 를 그릴지. 종료된 모임에서만 그리지 않는다. 요청 중에는 그린 채 `canEdit` 으로 막는다.
        public var showsCardMenu: Bool {
            !isEnded
        }

        /// 카드 `•••` 를 누를 수 있는지와 그 안의 「수정」
        public var canEdit: Bool {
            !isEnded && !isRequesting
        }

        /// 카드 `•••` 의 「삭제」. 알림을 보낸 스냅 포인트는 지우지 않는다.
        public func canDelete(_ snapPoint: SnapPoint) -> Bool {
            canEdit && !snapPoint.isSent
        }
    }

    public enum Action: Equatable {
        case task
        case retryTapped
        case snapPointsLoaded(Result<[SnapPoint], SnapPointError>)
        case helpTapped
        case helpDismissed
        case addTapped
        case recommendationTapped(SnapPointDraft)
        case editTapped(id: String)
        case deleteTapped(id: String)
        case editorNameChanged(String)
        case editorNotificationMessageChanged(String)
        case editorSaveTapped
        case editorDismissed
        /// 더했거나 고친 스냅 포인트
        case saved(SnapPoint)
        case deleted(id: String)
        case requestFailed(SnapPointError)
        case failureDismissed
        case delegate(Delegate)

        public enum Delegate: Equatable {
            /// 목록이 바뀌었다. 흐름이 상세·위젯·모임 관리 숫자를 맞춘다
            case snapPointsChanged([SnapPoint])
        }
    }

    @Dependency(\.snapPointClient) var snapPointClient

    public init() {}

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce(loading)
            Reduce(listEditing)
            Reduce(editorEditing)
            Reduce(responses)
        }
        .logged(as: Self.self, children: [])
    }
}

// MARK: - 리듀서

extension SnapPointSettingFeature {
    private func loading(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task, .retryTapped:
            guard !state.hasLoaded, state.screen != .loading else { return .none }
            state.screen = .loading
            return load(meetingID: state.meetingID)
        case let .snapPointsLoaded(.success(snapPoints)):
            state.screen = .idle
            state.hasLoaded = true
            state.snapPoints = snapPoints
            return .none
        case let .snapPointsLoaded(.failure(error)):
            state.screen = .loadFailed(
                message: FeatureErrorMessage.snapPointFailure(
                    for: error,
                    action: FeatureErrorMessage.MeetingAction.snapPointsLoadFailed
                )
            )
            return .none
        case .helpTapped:
            state.isHelpPresented.toggle()
            return .none
        case .helpDismissed:
            state.isHelpPresented = false
            return .none
        case .failureDismissed:
            state.screen = .idle
            return .none
        default:
            return .none
        }
    }

    private func listEditing(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .addTapped:
            guard state.canAdd else { return .none }
            state.editor = Editor()
            return .none
        case let .recommendationTapped(draft):
            guard state.canAdd else { return .none }
            state.isRequesting = true
            return add(draft, meetingID: state.meetingID)
        case let .editTapped(id):
            guard state.canEdit, let snapPoint = state.snapPoints.first(where: { $0.id == id }) else { return .none }
            state.editor = Editor(
                snapPointID: id,
                name: snapPoint.name,
                notificationMessage: snapPoint.notificationMessage
            )
            return .none
        case let .deleteTapped(id):
            guard let snapPoint = state.snapPoints.first(where: { $0.id == id }), state.canDelete(snapPoint) else {
                return .none
            }
            state.isRequesting = true
            return delete(id: id, meetingID: state.meetingID)
        default:
            return .none
        }
    }

    private func editorEditing(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .editorNameChanged(name):
            state.editor?.name = name
            return .none
        case let .editorNotificationMessageChanged(message):
            state.editor?.notificationMessage = message
            return .none
        case .editorSaveTapped:
            guard let editor = state.editor, editor.canSave, state.canEdit else { return .none }
            state.isRequesting = true
            let draft = SnapPointDraft(
                name: editor.name.trimmingCharacters(in: .whitespacesAndNewlines),
                notificationMessage: editor.notificationMessage
            )
            if let id = editor.snapPointID {
                return update(id: id, draft: draft, meetingID: state.meetingID)
            }
            return add(draft, meetingID: state.meetingID)
        case .editorDismissed:
            state.editor = nil
            return .none
        default:
            return .none
        }
    }

    private func responses(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .saved(snapPoint):
            state.isRequesting = false
            state.editor = nil
            if let index = state.snapPoints.firstIndex(where: { $0.id == snapPoint.id }) {
                state.snapPoints[index] = snapPoint
            } else {
                state.snapPoints.append(snapPoint)
            }
            return .send(.delegate(.snapPointsChanged(state.snapPoints)))
        case let .deleted(id):
            state.isRequesting = false
            state.snapPoints.removeAll { $0.id == id }
            return .send(.delegate(.snapPointsChanged(state.snapPoints)))
        case let .requestFailed(error):
            // 편집 시트가 덮고 있으면 오류 창이 가려진다. 시트를 닫고 띄운다.
            state.isRequesting = false
            state.editor = nil
            state.screen = .actionFailed(message: FeatureErrorMessage.message(for: error))
            return .none
        default:
            return .none
        }
    }
}

// MARK: - 효과

extension SnapPointSettingFeature {
    private func load(meetingID: String) -> Effect<Action> {
        .run { [snapPointClient] send in
            do {
                let snapPoints = try await snapPointClient.snapPoints(meetingID: meetingID)
                await send(.snapPointsLoaded(.success(snapPoints)))
            } catch {
                await send(.snapPointsLoaded(.failure(.wrapping(error))))
            }
        }
    }

    private func add(_ draft: SnapPointDraft, meetingID: String) -> Effect<Action> {
        .run { [snapPointClient] send in
            do {
                let snapPoint = try await snapPointClient.add(meetingID: meetingID, draft: draft)
                await send(.saved(snapPoint))
            } catch {
                await send(.requestFailed(.wrapping(error)))
            }
        }
    }

    private func update(id: String, draft: SnapPointDraft, meetingID: String) -> Effect<Action> {
        .run { [snapPointClient] send in
            do {
                let snapPoint = try await snapPointClient.update(meetingID: meetingID, snapPointID: id, draft: draft)
                await send(.saved(snapPoint))
            } catch {
                await send(.requestFailed(.wrapping(error)))
            }
        }
    }

    private func delete(id: String, meetingID: String) -> Effect<Action> {
        .run { [snapPointClient] send in
            do {
                try await snapPointClient.delete(meetingID: meetingID, snapPointID: id)
                await send(.deleted(id: id))
            } catch {
                await send(.requestFailed(.wrapping(error)))
            }
        }
    }
}
