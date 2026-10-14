import SwiftUI
import UIKit

/// 시각 고르기 휠. iOS 기본 시간 고르기(`UIDatePicker` 휠, 시·분) 하나다. 지금 시각은 쓰는 쪽이 넘긴다.
/// 오전/오후와 12·24시간 표시는 기기 설정을 따른다. 분은 `minuteInterval` 분 간격이다.
/// 넘긴 분이 간격에 맞지 않으면 바로 아래 칸에 놓는다. 휠을 돌리면 `onSelect` 로 새 시각을 알린다.
public struct DesignTimeWheel: View {
    private let selection: DesignClockTime
    private let minuteInterval: Int
    private let onSelect: @MainActor (DesignClockTime) -> Void

    public init(
        selection: DesignClockTime,
        minuteInterval: Int = 5,
        onSelect: @escaping @MainActor (DesignClockTime) -> Void
    ) {
        self.selection = selection
        self.minuteInterval = minuteInterval
        self.onSelect = onSelect
    }

    public var body: some View {
        // SwiftUI `DatePicker` 는 분 간격을 받지 않는다. 5분 간격 때문에 `UIDatePicker` 를 감싼다.
        DesignTimeWheelBridge(selection: selection, minuteInterval: minuteInterval, onSelect: onSelect)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// 시간 휠의 UIKit 몸통. `UIDatePicker`(`.time`, `.wheels`)를 감싼다. 값은 쓰는 쪽이 든다.
struct DesignTimeWheelBridge: UIViewRepresentable {
    let selection: DesignClockTime
    let minuteInterval: Int
    let onSelect: @MainActor (DesignClockTime) -> Void

    /// 시·분만 고르는 iOS 기본 휠. 언어·달력·시간대는 기기 설정 그대로 둔다.
    @MainActor
    static func makePicker(minuteInterval: Int) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.minuteInterval = max(minuteInterval, 1)
        return picker
    }

    /// 넘긴 시각을 간격에 맞춰 휠에 건다. 이미 같은 시각이면 건드리지 않는다(돌리는 중에 되감지 않게).
    @MainActor
    static func show(_ selection: DesignClockTime, minuteInterval: Int, in picker: UIDatePicker) {
        let target = selection.snapped(minuteInterval: minuteInterval)
        let calendar = wheelCalendar(of: picker)
        guard DesignClockTime(picker.date, calendar: calendar) != target,
              let date = target.date(on: picker.date, calendar: calendar)
        else { return }
        picker.setDate(date, animated: false)
    }

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = Self.makePicker(minuteInterval: minuteInterval)
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        picker.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        Self.show(selection, minuteInterval: minuteInterval, in: picker)
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: Context) {
        context.coordinator.parent = self
        picker.minuteInterval = max(minuteInterval, 1)
        Self.show(selection, minuteInterval: minuteInterval, in: picker)
    }

    /// 휠이 시각을 보이는 달력. `UIDatePicker.calendar` 를 읽으면 시간대가 기기 시간대로 돌아오므로 `timeZone` 을 다시 건다.
    static func wheelCalendar(of picker: UIDatePicker) -> Calendar {
        var calendar = picker.calendar ?? .current
        calendar.timeZone = picker.timeZone ?? .current
        return calendar
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: DesignTimeWheelBridge

        init(parent: DesignTimeWheelBridge) {
            self.parent = parent
        }

        @objc func valueChanged(_ picker: UIDatePicker) {
            parent.onSelect(DesignClockTime(picker.date, calendar: DesignTimeWheelBridge.wheelCalendar(of: picker)))
        }
    }
}
