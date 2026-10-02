import SharedDesignSystem
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
                    DesignText(
                        toastMessage,
                        style: TextStyle.ds.headline.regular,
                        color: Color.ds.text.neutral.inverse
                    )
                    .padding(.horizontal, CGFloat.ds.spacing.lg)
                    .padding(.vertical, CGFloat.ds.spacing.md)
                    .background(Color.ds.fill.neutral.inverse)
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._12))
                    .padding(.bottom, CGFloat.ds.spacing.xl)
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
    .background(Color.ds.overlay.dim._20)
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
    .background(Color.ds.overlay.dim._20)
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
    .background(Color.ds.overlay.dim._20)
}
