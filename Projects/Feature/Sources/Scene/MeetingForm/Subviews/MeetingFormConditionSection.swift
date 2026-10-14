import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 장소·연령대·최대 인원 수·성별 줄.
struct MeetingFormConditionSection: View {
    @Bindable var store: StoreOf<MeetingFormFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                store.send(.placeTapped)
            } label: {
                MeetingFormRow("장소", value: store.place?.name, showsSeparator: true)
            }
            .buttonStyle(.plain)
            ageRow
            capacityRow
            genderRow
        }
    }

    private var ageRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                store.send(.ageRowTapped)
            } label: {
                // 펼치면 구분선은 칩 묶음 아래로 간다(시안 Row chips)
                MeetingFormRow(
                    "연령대",
                    value: MeetingFormFormat.ageSummary(option: store.age, range: store.ageRange),
                    showsSeparator: !store.isAgeExpanded
                )
            }
            .buttonStyle(.plain)
            if store.isAgeExpanded {
                VStack(alignment: .leading, spacing: MeetingFormConditionLayout.expandedSpacing) {
                    // 시안: 칩 묶음과 고르기 칸 사이 8
                    VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                        ageChips
                        if store.age == .custom {
                            customAgeRow
                        }
                    }
                    if store.age != .anyone,
                       let caption = MeetingFormFormat.birthYearCaption(
                           range: store.ageRange,
                           thisYear: store.today?.year
                       ) {
                        DesignText(caption, style: TextStyle.ds.subtext.regular, color: Color.ds.text.neutral.primary)
                            .padding(.horizontal, MeetingFormConditionLayout.captionHorizontalPadding)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: MeetingFormConditionLayout.captionHeight,
                                alignment: .leading
                            )
                            .background(
                                RoundedRectangle(cornerRadius: CGFloat.ds.radius._6)
                                    .fill(Color.ds.overlay.gray.default)
                            )
                    }
                }
                .meetingFormExpandedPadding(top: CGFloat.ds.spacing.xs)
                .overlay(alignment: .bottom) {
                    DesignFormRowSeparator()
                }
            }
        }
    }

    private var ageChips: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            HStack(spacing: CGFloat.ds.spacing.sm) {
                ForEach(Array(MeetingAgeOption.allCases.prefix(5)), id: \.self) { option in
                    ageChip(option)
                }
            }
            HStack(spacing: CGFloat.ds.spacing.sm) {
                ForEach(Array(MeetingAgeOption.allCases.dropFirst(5)), id: \.self) { option in
                    ageChip(option)
                }
            }
        }
    }

    private func ageChip(_ option: MeetingAgeOption) -> some View {
        // `isEditing` 을 넘겨야 누르는 칩 생성자가 골라진다(닫기 칩 생성자와 겹친다). 직접 입력 칩 끝에는 아래 꺾쇠(시안)
        DesignChip(
            option.title,
            style: store.age == option ? .filled : .outlined,
            isEditing: false,
            trailingIcon: option == .custom ? Image.ds.icon.chevron.down : nil
        ) {
            store.send(.ageSelected(option))
        }
        .accessibilityAddTraits(store.age == option ? .isSelected : [])
    }

    /// 시안 Picker: 고르기 칸 둘 사이에 「~」.
    private var customAgeRow: some View {
        let ages = MeetingFormOptions.customAges.map(MeetingFormFormat.ageText)
        return HStack(spacing: MeetingFormConditionLayout.pickerSpacing) {
            DesignPickerCell(
                value: store.customMinAge.map(MeetingFormFormat.ageText),
                placeholder: "최소 나이",
                options: ages
            ) { text in
                if let age = MeetingFormFormat.age(fromText: text) {
                    store.send(.customMinAgeSelected(age))
                }
            }
            DesignText("~", style: TextStyle.ds.caption1.semiBold, color: Color.ds.text.neutral.primary)
            DesignPickerCell(
                value: store.customMaxAge.map(MeetingFormFormat.ageText),
                placeholder: "최대 나이",
                options: ages
            ) { text in
                if let age = MeetingFormFormat.age(fromText: text) {
                    store.send(.customMaxAgeSelected(age))
                }
            }
        }
    }

    private var capacityRow: some View {
        Menu {
            ForEach(MeetingFormOptions.capacities, id: \.self) { count in
                Button {
                    store.send(.capacitySelected(count))
                } label: {
                    MeetingFormMenuLabel(title: "\(count)명", isSelected: store.capacity == count)
                }
            }
        } label: {
            MeetingFormRow(
                "최대 인원 수",
                value: store.capacity.map { "\($0)명" },
                trailingIcon: Image.ds.icon.chevronUpDown.outlined,
                showsSeparator: true
            )
        }
        .buttonStyle(.plain)
    }

    private var genderRow: some View {
        Menu {
            ForEach(MeetingFormOptions.genders, id: \.self) { gender in
                Button {
                    store.send(.genderSelected(gender))
                } label: {
                    MeetingFormMenuLabel(title: MeetingFormFormat.gender(gender), isSelected: store.gender == gender)
                }
            }
        } label: {
            MeetingFormRow("성별", value: MeetingFormFormat.gender(store.gender))
        }
        .buttonStyle(.plain)
    }
}

private enum MeetingFormConditionLayout {
    /// 시안 Row chips 의 칩·고르기 칸 묶음과 출생연도 안내 사이.
    static let expandedSpacing: CGFloat = 20
    /// 시안 출생연도 안내 칸: 높이 36, 좌우 14.
    static let captionHeight: CGFloat = 36
    static let captionHorizontalPadding: CGFloat = 14
    /// 시안 Picker: 칸·「~」·칸 사이 10.
    static let pickerSpacing: CGFloat = 10
}
