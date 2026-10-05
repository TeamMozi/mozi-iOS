import SwiftUI

extension View {
    /// 화면 상태를 띄운다. 불러오는 중에도 입력을 막지 않는다.
    /// 동작 실패 얼럿의 「확인」 은 `onDismiss` 를 부른다. `onDismiss` 가 상태를 `.idle` 로 돌려야 얼럿이 닫힌다.
    /// `onRetry` 가 없으면 불러오기 실패 화면에 「다시 시도」 를 그리지 않는다.
    public func screenStatus(
        _ status: ScreenStatus,
        onRetry: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            ScreenStatusModifier(
                status: status,
                onRetry: onRetry,
                onDismiss: onDismiss
            )
        )
    }
}

private struct ScreenStatusModifier: ViewModifier {
    let status: ScreenStatus
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                if status.isLoading {
                    ProgressView()
                        .tint(Color.ds.text.neutral.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                if let message = status.loadFailureMessage {
                    ScreenStatusLoadFailedView(message: message, onRetry: onRetry)
                }
            }
            // 표시 여부는 상태에서만 읽는다. 닫기는 「확인」 → onDismiss 가 상태를 바꿔서 한다.
            .alert(
                status.actionFailureMessage ?? "",
                isPresented: .constant(status.actionFailureMessage != nil)
            ) {
                Button("확인", role: .cancel, action: onDismiss)
            }
    }
}

/// 불러오기 실패 임시 화면. 실제 모양은 시안이 나오면 이 자리에서 바꾼다.
private struct ScreenStatusLoadFailedView: View {
    let message: String
    let onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: CGFloat.ds.spacing.lg) {
            DesignText(
                message,
                style: TextStyle.ds.body.medium,
                color: Color.ds.text.neutral.secondary,
                alignment: .center
            )

            if let onRetry {
                DesignButton("다시 시도", variant: .secondary, size: .md, action: onRetry)
            }
        }
        .padding(.horizontal, CGFloat.ds.layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
    }
}
