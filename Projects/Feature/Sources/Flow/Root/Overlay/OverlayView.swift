import SwiftUI
import ThirdParty

public struct OverlayView: View {
    @Bindable public var store: StoreOf<OverlayFeature>

    public init(store: StoreOf<OverlayFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            if let toastMessage = store.toastMessage {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.primary.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 24)
                        .onTapGesture {
                            store.send(.dismissToast)
                        }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.toastMessage)
        .alert(
            store.alertMessage ?? "",
            isPresented: Binding(
                get: { store.alertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.dismissAlert)
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                store.send(.dismissAlert)
            }
        }
    }
}

// MARK: - Preview

#Preview("Overlay / Empty") {
    OverlayView(
        store: Store(initialState: OverlayFeature.State()) {
            OverlayFeature()
        }
    )
    .background(Color.black.opacity(0.2))
}

#Preview("Overlay / Toast") {
    OverlayView(
        store: Store(
            initialState: OverlayFeature.State(
                toastMessage: "네트워크 연결을 확인해 주세요"
            )
        ) {
            OverlayFeature()
        }
    )
    .background(Color.black.opacity(0.2))
}

#Preview("Overlay / Alert") {
    OverlayView(
        store: Store(
            initialState: OverlayFeature.State(
                alertMessage: "알 수 없는 오류가 발생했어요."
            )
        ) {
            OverlayFeature()
        }
    )
    .background(Color.black.opacity(0.2))
}
