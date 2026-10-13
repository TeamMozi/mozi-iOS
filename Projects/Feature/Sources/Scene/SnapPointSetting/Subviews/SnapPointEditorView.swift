import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 스냅 포인트 편집 시트. 위는 촬영 화면 미리보기, 아래는 입력 칸 둘이다.
/// 시안의 카메라 배경은 흐린 단색으로 대신한다. 위쪽은 시안대로 늘 어두운 색으로 그리고, 알림만 기기 모드를 따른다.
struct SnapPointEditorView: View {
    @Bindable var store: StoreOf<SnapPointSettingFeature>
    @Environment(\.colorScheme) private var colorScheme
    @State private var contentHeight: CGFloat = 0
    @State private var keyboardIgnoringHeight: CGFloat = 0

    /// 키보드를 무시한 높이가 더 크면 그 차만큼 키보드가 가리고 있다
    private var isKeyboardVisible: Bool {
        keyboardIgnoringHeight > contentHeight
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                preview
                inputSheet
                    .environment(\.colorScheme, colorScheme)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                contentHeight = height
            }
            .background {
                Color.clear
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        keyboardIgnoringHeight = height
                    }
            }
            .background(Color.ds.fill.neutral.subtle.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.send(.editorDismissed)
                    } label: {
                        DesignToolbarIcon(Image.ds.icon.close.outlined)
                    }
                    .accessibilityLabel("닫기")
                }
                ToolbarItem(placement: .principal) {
                    DesignToolbarTitle("스냅 포인트")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.editorSaveTapped)
                    } label: {
                        DesignText("완료", style: TextStyle.ds.headline.medium)
                    }
                    .disabled(!(store.editor?.canSave ?? false) || store.isRequesting)
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }

    private var name: String {
        store.editor?.name ?? ""
    }

    private var notificationMessage: String {
        store.editor?.notificationMessage ?? ""
    }

    private var previewName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? SnapPointEditorCopy.namePlaceholder : name
    }

    private var previewMessage: String {
        notificationMessage.isEmpty ? SnapPointEditorCopy.messagePlaceholder : notificationMessage
    }

    private var preview: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: SnapPointEditorLayout.chipTopInset)
            DesignText(
                previewName,
                style: TextStyle.ds.title2.semiBold,
                alignment: .center
            )
            .padding(SnapPointEditorLayout.chipPadding)
            .background(Color.ds.overlay.dim._60, in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._12))
            .padding(.horizontal, CGFloat.ds.layout.margin)
            Spacer(minLength: SnapPointEditorLayout.notificationToSheetSpacing)
            // 시안 라이트(`2835:128879`)는 밝은 유리에 어두운 글자다. 알림만 기기 모드를 따른다
            notification
                .environment(\.colorScheme, colorScheme)
                .padding(.horizontal, CGFloat.ds.layout.margin)
            Spacer()
                .frame(height: SnapPointEditorLayout.notificationToSheetSpacing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("미리보기, \(previewName), \(previewMessage)")
    }

    private var notification: some View {
        HStack(spacing: SnapPointEditorLayout.notificationSpacing) {
            Image.ds.brand.logoBlack
                .resizable()
                .scaledToFit()
                .frame(width: SnapPointEditorLayout.logoSize.width, height: SnapPointEditorLayout.logoSize.height)
                .frame(width: SnapPointEditorLayout.appIconSize, height: SnapPointEditorLayout.appIconSize)
                .background(
                    Color.ds.button.background.main.default,
                    in: RoundedRectangle(cornerRadius: SnapPointEditorLayout.appIconRadius)
                )
            VStack(alignment: .leading, spacing: SnapPointEditorLayout.notificationTextSpacing) {
                DesignText(previewName, style: TextStyle.ds.caption1.semiBold, lineLimit: 1)
                DesignText(previewMessage, style: TextStyle.ds.caption1.regular, lineLimit: 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(SnapPointEditorLayout.notificationPadding)
        .frame(minHeight: SnapPointEditorLayout.notificationMinHeight)
        .background(
            Color.ds.button.background.icon.default,
            in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._24)
        )
    }

    private var inputSheet: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.ds.fill.neutral.strong)
                .frame(width: SnapPointEditorLayout.handleSize.width, height: SnapPointEditorLayout.handleSize.height)
            VStack(spacing: SnapPointEditorLayout.fieldSpacing) {
                DesignTextField(
                    "스냅 포인트",
                    text: Binding(get: { name }, set: { store.send(.editorNameChanged($0)) }),
                    placeholder: SnapPointEditorCopy.namePlaceholder,
                    maxLength: .max
                )
                DesignTextArea(
                    "알림 메세지",
                    text: Binding(
                        get: { notificationMessage },
                        set: { store.send(.editorNotificationMessageChanged($0)) }
                    ),
                    placeholder: SnapPointEditorCopy.messagePlaceholder,
                    maxLength: SnapPointLimit.notificationMessageMaxLength
                )
            }
            .padding(.vertical, SnapPointEditorLayout.fieldVerticalPadding)
            .padding(.horizontal, CGFloat.ds.layout.margin)
        }
        .padding(.top, SnapPointEditorLayout.sheetTopPadding)
        .padding(
            .bottom,
            isKeyboardVisible
                ? SnapPointEditorLayout.sheetBottomPaddingAboveKeyboard
                : SnapPointEditorLayout.sheetBottomPadding
        )
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: SnapPointEditorLayout.sheetRadius,
                topTrailingRadius: SnapPointEditorLayout.sheetRadius
            )
            .fill(Color.ds.fill.neutral.default)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

/// 미리보기와 칸에 쓰는 시안 글자
private enum SnapPointEditorCopy {
    static let namePlaceholder = "왓츠인마이백"
    static let messagePlaceholder = "가장 나다운 소지품을 찍어보세요👀"
}

/// 시안 `2835:128879` 의 `Snap point`·`Notification`·`bottom sheet` 값
private enum SnapPointEditorLayout {
    /// 시안은 화면 위에서 219 다. 헤더(99) 아래부터 잰 값이다
    static let chipTopInset: CGFloat = 120
    static let chipPadding: CGFloat = 10
    static let notificationToSheetSpacing: CGFloat = 20
    static let notificationPadding: CGFloat = 14
    static let notificationSpacing: CGFloat = 10
    static let notificationTextSpacing: CGFloat = 2
    static let notificationMinHeight: CGFloat = 64
    static let appIconSize: CGFloat = 38
    static let appIconRadius: CGFloat = 7.6
    static let logoSize = CGSize(width: 28.5, height: 13.3)
    static let sheetRadius: CGFloat = 38
    static let sheetTopPadding: CGFloat = 10
    /// 시안 `bottom sheet`(334) 안 틀(324, 아래 여백 10)이 내용(308)보다 16 길다. 10 + 16 + 10 = 36.
    /// 홈 인디케이터 영역(34)을 따로 비우지 않고 이 값이 덮는다
    static let sheetBottomPadding: CGFloat = 36
    /// 키보드 위에는 홈 인디케이터 몫이 없어 틀 아래 여백만 남긴다
    static let sheetBottomPaddingAboveKeyboard: CGFloat = 10
    static let handleSize = CGSize(width: 34, height: 5)
    static let fieldVerticalPadding: CGFloat = 20
    static let fieldSpacing: CGFloat = 20
}
