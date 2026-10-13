import Domain
import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 모임 상세 흐름을 고른 관점으로 띄운다. 관점을 바꾸면 store 와 화면을 처음부터 다시 만들고, 가짜 서버는 그대로 둔다.
///
/// 흐름이 자기 NavigationStack 을 가지므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct MeetingDetailDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: MeetingDetailDemoState
    @State private var backend: MeetingDetailDemoBackend
    @State private var store: StoreOf<DemoMeetingDetailFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        let backend = MeetingDetailDemoBackend(photoURL: DemoPhoto.url)
        _demoState = State(initialValue: .host)
        _backend = State(initialValue: backend)
        _store = State(initialValue: Self.makeStore(for: .host, backend: backend))
    }

    var body: some View {
        MeetingDetailFlowView(store: store.scope(state: \.flow, action: \.flow))
            .id(generation)
            .onChange(of: store.isFinished) { _, isFinished in
                if isFinished {
                    onExit()
                }
            }
            .demoMenu(
                shortLabel: demoState.shortTitle,
                options: MeetingDetailDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
                selectedID: demoState.rawValue,
                onSelect: { id in
                    select(MeetingDetailDemoState(rawValue: id) ?? .host)
                },
                onExit: onExit
            )
    }

    private func select(_ state: MeetingDetailDemoState) {
        demoState = state
        store = Self.makeStore(for: state, backend: backend)
        generation += 1
    }

    private static func makeStore(
        for state: MeetingDetailDemoState,
        backend: MeetingDetailDemoBackend
    ) -> StoreOf<DemoMeetingDetailFeature> {
        Store(
            initialState: DemoMeetingDetailFeature.State(
                flow: MeetingDetailFlowFeature.State(detailOf: MeetingDetailDemoBackend.meetingID)
            )
        ) {
            DemoMeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient = MeetingDetailDemoClients.meetingClient(backend, as: state)
            $0.snapPointClient = MeetingDetailDemoClients.snapPointClient(backend)
            $0.seriesClient = MeetingDetailDemoClients.seriesClient(photoURL: DemoPhoto.url)
        }
    }
}
