import SharedDesignSystem
import SwiftUI

/// 「헤더·탭바」 화면의 하단 버튼 영역 견본 다섯. Figma `Bottom Button Area` 변형 이름과 순서다.
public enum BottomButtonAreaSample: String, CaseIterable, Identifiable {
    case singleBasic
    case split5To5
    case split3To7
    case singleCaption
    case singleLink

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .singleBasic: "Single_Basic"
        case .split5To5: "Split 5:5"
        case .split3To7: "Split 3:7"
        case .singleCaption: "Single_Caption"
        case .singleLink: "Single_Link"
        }
    }

    public var arrangement: BottomButtonArrangement {
        switch self {
        case .singleBasic, .singleCaption, .singleLink: .single
        case .split5To5: .split5To5
        case .split3To7: .split3To7
        }
    }

    /// 윗줄이 있는 두 견본만 위쪽 선을 켠다.
    public var showsTopBorder: Bool {
        switch self {
        case .singleCaption, .singleLink: true
        case .singleBasic, .split5To5, .split3To7: false
        }
    }
}

/// 「헤더·탭바」 화면에서 전체 화면으로 여는 견본 셋.
public enum FrameSample: String, CaseIterable, Identifiable {
    case header
    case tabBar
    case bottomSheet

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .header: "헤더"
        case .tabBar: "탭바"
        case .bottomSheet: "바텀시트"
        }
    }
}

/// 헤더 견본의 변형 다섯. 고르면 그 헤더를 단 화면이 쌓인다.
public enum HeaderSample: String, CaseIterable, Identifiable {
    case transparent
    case filled
    case textButton
    case twoTrailingButtons
    case leadingTitle

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .transparent: "투명"
        case .filled: "채움"
        case .textButton: "글자 버튼"
        case .twoTrailingButtons: "오른쪽 버튼 둘"
        case .leadingTitle: "왼쪽 정렬 제목"
        }
    }

    public var background: DesignHeaderBackground {
        self == .filled ? .filled : .transparent
    }
}

/// 바텀시트 견본 넷. 제목 자리(가운데·왼쪽 정렬)와 높이(large·medium)를 엮는다. 높이는 쓰는 화면이 고른다.
public enum BottomSheetSample: String, CaseIterable, Identifiable {
    case centeredLarge
    case centeredMedium
    case leadingTitleLarge
    case leadingTitleMedium

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .centeredLarge: "기본 · large"
        case .centeredMedium: "기본 · medium"
        case .leadingTitleLarge: "왼쪽 정렬 제목 · large"
        case .leadingTitleMedium: "왼쪽 정렬 제목 · medium"
        }
    }

    public var detent: PresentationDetent {
        switch self {
        case .centeredLarge, .leadingTitleLarge: .large
        case .centeredMedium, .leadingTitleMedium: .medium
        }
    }

    public var isLeadingTitle: Bool {
        switch self {
        case .leadingTitleLarge, .leadingTitleMedium: true
        case .centeredLarge, .centeredMedium: false
        }
    }
}
