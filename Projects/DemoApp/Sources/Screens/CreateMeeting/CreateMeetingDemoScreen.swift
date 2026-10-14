import Domain
import Feature
import MoziDemoKit
import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 모임 만들기 시트를 고른 데모 상태로 띄운다. 상태를 고를 때마다 store 와 화면을 처음부터 다시 만든다.
///
/// 시트 안 흐름이 자기 NavigationStack 을 가지므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct CreateMeetingDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: CreateMeetingDemoState
    @State private var store: StoreOf<DemoCreateMeetingFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .firstCreate)
        _store = State(initialValue: Self.makeStore(for: .firstCreate))
    }

    var body: some View {
        CreateMeetingDemoBase(store: store)
            .id(generation)
            .demoMenu(
                shortLabel: demoState.shortTitle,
                options: CreateMeetingDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
                selectedID: demoState.rawValue,
                onSelect: { id in
                    select(CreateMeetingDemoState(rawValue: id) ?? .firstCreate)
                },
                onExit: onExit
            )
    }

    private func select(_ state: CreateMeetingDemoState) {
        demoState = state
        store = Self.makeStore(for: state)
        generation += 1
    }

    private static func makeStore(for state: CreateMeetingDemoState) -> StoreOf<DemoCreateMeetingFeature> {
        let posterURL = CreateMeetingDemoPoster.fileURL()
        return Store(initialState: state.initialState(posterURL: posterURL)) {
            DemoCreateMeetingFeature()
        } withDependencies: {
            $0.meetingClient = CreateMeetingDemoClients.meetingClient(for: state, posterURL: posterURL)
            $0.seriesClient = CreateMeetingDemoClients.seriesClient(for: state)
            $0.placeClient = CreateMeetingDemoClients.placeClient(for: state)
            $0.interestClient = .previewValue
        }
    }
}

/// 시트 뒤 바탕. 다시 여는 버튼과 올라온 모임 한 줄이 있다.
private struct CreateMeetingDemoBase: View {
    @Bindable var store: StoreOf<DemoCreateMeetingFeature>

    var body: some View {
        VStack(spacing: CGFloat.ds.spacing.lg) {
            Spacer()
            if let line = store.createdLine {
                DesignText(line, style: TextStyle.ds.body.semiBold, alignment: .center)
            }
            Button {
                store.send(.openTapped)
            } label: {
                Text("모임 만들기 열기")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.main)
            .controlSize(.large)
            Spacer()
        }
        .padding(.horizontal, CGFloat.ds.layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .designSheet(item: $store.scope(state: \.flow, action: \.flow)) { flowStore in
            CreateMeetingFlowView(store: flowStore)
        }
        .screenStatus(store.screen) {
            store.send(.noticeDismissed)
        }
    }
}
