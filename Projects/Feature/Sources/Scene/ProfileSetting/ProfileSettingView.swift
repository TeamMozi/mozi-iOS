import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct ProfileSettingView: View {
    @Bindable public var store: StoreOf<ProfileSettingFeature>

    public init(store: StoreOf<ProfileSettingFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: ProfileSettingLayout.sectionSpacing) {
                ProfilePhotoPicker(photoData: store.pickedPhotoData) { data in
                    store.send(.photoPicked(data))
                }

                VStack(alignment: .leading, spacing: ProfileSettingLayout.fieldSpacing) {
                    DesignTextField(
                        "이름",
                        text: $store.nickname.sending(\.nicknameChanged),
                        placeholder: "이름",
                        maxLength: UserLimit.nicknameMaxLength
                    )

                    DesignDropdownRow("생년월일", isRequired: true, cells: birthDateCells)

                    DesignDropdownRow("성별", isRequired: true, cells: [genderCell])

                    DesignTextArea(
                        "소개",
                        text: $store.introduction.sending(\.introductionChanged),
                        placeholder: "소개(선택)",
                        maxLength: UserLimit.introductionMaxLength
                    )
                }

                Text(Self.termsNotice)
                    .font(ProfileSettingLayout.termsStyle.font)
                    .kerning(ProfileSettingLayout.termsStyle.letterSpacing)
                    .lineSpacing(ProfileSettingLayout.termsStyle.additionalLineSpacing)
                    .multilineTextAlignment(.center)
                    .opacity(ProfileSettingLayout.termsOpacity)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, ProfileSettingLayout.horizontalPadding)
            .padding(.top, ProfileSettingLayout.contentTopPadding)
        }
        .scrollDismissesKeyboard(.interactively)
        .disabled(store.isLoggingOut)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.backTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.chevron.left)
                }
                .accessibilityLabel("뒤로")
                .disabled(store.isLoggingOut)
            }
        }
        .bottomButtonArea {
            BottomButtonArea(.single) {
                Button {
                    store.send(.startTapped)
                } label: {
                    Text("시작하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.main)
                .controlSize(.large)
                .disabled(store.isStartEnabled == false)
            }
        }
        .screenStatus(store.screen, onDismiss: { store.send(.failureDismissed) })
        .task {
            store.send(.onAppear)
        }
    }

    private var birthDateCells: [DesignDropdownCell] {
        [
            numberCell(
                value: store.birthYear,
                unit: "년",
                options: store.yearOptions
            ) { store.send(.birthYearSelected($0)) },
            numberCell(
                value: store.birthMonth,
                unit: "월",
                options: store.monthOptions
            ) { store.send(.birthMonthSelected($0)) },
            numberCell(
                value: store.birthDay,
                unit: "일",
                options: store.dayOptions
            ) { store.send(.birthDaySelected($0)) },
        ]
    }

    /// 칸 글자와 메뉴 글자가 같아야 메뉴에 지금 값이 표시되므로 둘 다 단위를 붙인다. 단위만 쓰면 placeholder 다
    private func numberCell(
        value: Int?,
        unit: String,
        options: [Int],
        onSelect: @escaping @MainActor (Int) -> Void
    ) -> DesignDropdownCell {
        DesignDropdownCell(
            value: value.map { "\($0)\(unit)" },
            placeholder: unit,
            options: options.map { "\($0)\(unit)" },
            onSelect: { label in
                guard let number = Int(label.dropLast(unit.count)) else { return }
                onSelect(number)
            }
        )
    }

    private var genderCell: DesignDropdownCell {
        DesignDropdownCell(
            value: store.gender.map(Self.genderLabel),
            placeholder: "성별",
            options: ProfileSettingFeature.genderOptions.map(Self.genderLabel),
            onSelect: { label in
                let gender = ProfileSettingFeature.genderOptions
                    .first { Self.genderLabel($0) == label }
                guard let gender else { return }
                store.send(.genderSelected(gender))
            }
        )
    }

    private static func genderLabel(_ gender: Gender) -> String {
        switch gender {
        case .male: "남자"
        case .female: "여자"
        }
    }

    /// 눌러도 동작이 없는 안내 문장. 「이용 약관」「개인정보 보호 정책」 만 강조한다
    private static var termsNotice: AttributedString {
        let parts: [(String, Bool)] = [
            ("시작하기를 누르면 모지의 ", false),
            ("이용 약관", true),
            ("에 동의하며\n", false),
            ("개인정보 보호 정책", true),
            ("을 확인한 것으로 간주됩니다.", false),
        ]
        return parts.reduce(into: AttributedString()) { result, part in
            var piece = AttributedString(part.0)
            if part.1 {
                piece.font = ProfileSettingLayout.termsEmphasisStyle.font
                piece.foregroundColor = Color.ds.button.label.text.accent
            } else {
                piece.foregroundColor = Color.ds.text.neutral.tertiary
            }
            result += piece
        }
    }
}

private enum ProfileSettingLayout {
    static let horizontalPadding = CGFloat.ds.layout.margin
    /// 시안은 사진이 헤더 안으로 10pt 겹치고 헤더가 기본 바보다 2pt 낮아, 바 끝에서 12pt 위로 올린다
    static let contentTopPadding: CGFloat = -12
    /// 사진 ~ 입력 묶음 ~ 약관 문장
    static let sectionSpacing: CGFloat = 30
    static let fieldSpacing: CGFloat = 22
    static let termsStyle = TextStyle.ds.caption1.regular
    static let termsEmphasisStyle = TextStyle.ds.caption1.medium
    static let termsOpacity: Double = 0.8
}

// MARK: - Preview

#Preview("ProfileSetting / Empty") {
    NavigationStack {
        ProfileSettingView(
            store: Store(initialState: ProfileSettingFeature.State()) {
                ProfileSettingFeature()
            }
        )
    }
}

#Preview("ProfileSetting / Filled") {
    NavigationStack {
        ProfileSettingView(
            store: Store(
                initialState: ProfileSettingFeature.State(
                    nickname: "수연",
                    birthYear: 1990,
                    birthMonth: 1,
                    birthDay: 1,
                    gender: .female,
                    introduction: "심심해요"
                )
            ) {
                ProfileSettingFeature()
            }
        )
    }
}
