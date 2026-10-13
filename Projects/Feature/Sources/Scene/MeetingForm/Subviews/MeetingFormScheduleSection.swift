import SharedDesignSystem
import SwiftUI
import ThirdParty

/// 「날짜 및 시간」 줄과 펼친 달력·시간 휠. 지난 날은 고를 수 없다.
struct MeetingFormScheduleSection: View {
    @Bindable var store: StoreOf<MeetingFormFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                MeetingFormRowLabel("날짜 및 시간")
                Spacer(minLength: CGFloat.ds.spacing.sm)
                HStack(spacing: MeetingFormScheduleLayout.chipSpacing) {
                    chip(store.startDay.map(MeetingFormFormat.date) ?? "날짜", field: .date)
                    chip(store.startTime.map(MeetingFormFormat.time) ?? "시간", field: .time)
                }
            }
            .padding(.horizontal, CGFloat.ds.spacing.lg)
            .frame(height: MeetingFormPartsLayout.rowHeight)
            .overlay(alignment: .bottom) {
                DesignFormRowSeparator()
            }
            if store.expandedScheduleField == .date, let today = store.today, let month = store.displayedMonth {
                // 시안 Row calendar 의 구분선은 줄 밖으로 잘려 보이지 않는다
                DesignCalendar(
                    month: month,
                    selection: store.startDay,
                    today: today,
                    minimumMonth: today.calendarMonth,
                    isSelectable: { day in day >= today },
                    onSelect: { store.send(.daySelected($0)) },
                    onMonthChange: { store.send(.monthChanged($0)) }
                )
                .meetingFormExpandedPadding(top: CGFloat.ds.spacing.sm)
            }
            if store.expandedScheduleField == .time {
                DesignTimeWheel(selection: store.startTime ?? MeetingFormScheduleLayout.wheelPlaceholder) {
                    store.send(.timeSelected($0))
                }
                .meetingFormExpandedPadding(top: CGFloat.ds.spacing.sm)
                .overlay(alignment: .bottom) {
                    DesignFormRowSeparator()
                }
            }
        }
    }

    /// 날짜·시각 칩. 펼친 쪽이 편집 중 모양이다(디자인 시스템 알약형 칩).
    private func chip(_ text: String, field: MeetingFormFeature.ScheduleField) -> some View {
        let isExpanded = store.expandedScheduleField == field
        return DesignChip(text, style: .pill, isEditing: isExpanded) {
            store.send(.scheduleFieldToggled(field))
        }
        .accessibilityAddTraits(isExpanded ? .isSelected : [])
    }
}

private enum MeetingFormScheduleLayout {
    /// 시안 Trailing(Date and Time) 의 칩 사이.
    static let chipSpacing: CGFloat = 6
    /// 시각을 아직 고르지 않았을 때 휠이 서 있는 자리. 값이 아니라 그림이다.
    static let wheelPlaceholder = DesignClockTime(hour: 12, minute: 0)
}
