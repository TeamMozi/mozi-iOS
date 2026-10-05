import SharedDesignSystem
import SwiftUI

/// 입력 화면. 입력 부품 6종을 시안 상태별로 늘어놓는다.
/// 글자 입력·글자 수 끊기·체크·토글·칩·메뉴·드롭다운 메뉴가 실제로 동작한다.
struct InputGalleryView: View {
    var body: some View {
        GalleryPage(.input) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
                TextFieldGallerySection()
                TextAreaGallerySection()
                DropdownGallerySection()
                CheckboxGallerySection()
                ToggleGallerySection()
                ChipGallerySection()
                SearchGallerySection()
                StatusMenuGallerySection()
            }
        }
    }
}

/// Input 한 줄. 칸을 누르면 입력 중 테두리가 켜진다.
private struct TextFieldGallerySection: View {
    @State private var name = ""
    @State private var nickname = "모지"
    @State private var longValue = InputGallerySample.longSingleLine

    var body: some View {
        GallerySection("Input · 한 줄") {
            InputGalleryCaption("입력 전 · 필수 · 누르면 입력 중")
            DesignTextField("이름", text: $name, placeholder: "이름", maxLength: 10, isRequired: true)
            InputGalleryCaption("입력 뒤")
            DesignTextField("닉네임", text: $nickname, placeholder: "닉네임", maxLength: 10)
            InputGalleryCaption("10자보다 긴 값이 넘어오면 받자마자 10자로 자른다")
            DesignTextField("긴 값", text: $longValue, placeholder: "긴 값", maxLength: 10)
        }
    }
}

/// Input 여러 줄과 캡션.
private struct TextAreaGallerySection: View {
    @State private var intro = ""
    @State private var filledIntro = "심심해요"
    @State private var longIntro = InputGallerySample.longMultiLine
    @State private var caption = ""

    var body: some View {
        GallerySection("Input · 여러 줄 · 캡션") {
            InputGalleryCaption("입력 전 · 누르면 입력 중")
            DesignTextArea("소개", text: $intro, placeholder: "소개(선택)", maxLength: 50)
            InputGalleryCaption("입력 뒤")
            DesignTextArea("소개", text: $filledIntro, placeholder: "소개(선택)", maxLength: 50)
            InputGalleryCaption("50자보다 긴 값 · 55/50 으로 보이고 지우기만 된다")
            DesignTextArea("긴 소개", text: $longIntro, placeholder: "소개(선택)", maxLength: 50)
            InputGalleryCaption("캡션")
            DesignTextArea(text: $caption, placeholder: "캡션 추가...", maxLength: 50, style: .caption)
        }
    }
}

/// Input 드롭다운 줄. 칸을 누르면 메뉴가 뜨고, 고른 값이 칸에 보인다.
private struct DropdownGallerySection: View {
    @State private var year: String?
    @State private var month: String?
    @State private var day: String?
    @State private var gender: String? = "여자"

    var body: some View {
        GallerySection("Input · 드롭다운 줄") {
            InputGalleryCaption("입력 전 · 필수 · 칸을 누르면 메뉴")
            DesignDropdownRow("생년월일", isRequired: true, cells: [
                DesignDropdownCell(value: year, placeholder: "년", options: InputGallerySample.years) { year = $0 },
                DesignDropdownCell(value: month, placeholder: "월", options: InputGallerySample.months) { month = $0 },
                DesignDropdownCell(value: day, placeholder: "일", options: InputGallerySample.days) { day = $0 },
            ])
            InputGalleryCaption("칸 하나 · 입력 뒤")
            DesignDropdownRow("성별", cells: [
                DesignDropdownCell(value: gender, placeholder: "성별", options: InputGallerySample.genders) {
                    gender = $0
                },
            ])
        }
    }
}

/// Checkbox 세 꼴의 해제·선택. 누르면 바뀐다.
private struct CheckboxGallerySection: View {
    @State private var checkOff = false
    @State private var checkOn = true
    @State private var orderOff = false
    @State private var orderOn = true
    @State private var voteOff = false
    @State private var voteOn = true

    var body: some View {
        GallerySection("Checkbox · 누르면 바뀐다") {
            InputGalleryCaption("회색 체크 · 해제 · 선택")
            HStack(spacing: CGFloat.ds.spacing.lg) {
                DesignCheckbox("회색 체크 해제", isOn: $checkOff, style: .check)
                DesignCheckbox("회색 체크 선택", isOn: $checkOn, style: .check)
            }
            InputGalleryCaption("번호 · 해제 · 선택")
            HStack(spacing: CGFloat.ds.spacing.lg) {
                DesignCheckbox("번호 해제", isOn: $orderOff, style: .order(2))
                DesignCheckbox("번호 선택", isOn: $orderOn, style: .order(2))
            }
            InputGalleryCaption("검정 체크 · 해제 · 선택")
            HStack(spacing: CGFloat.ds.spacing.lg) {
                DesignCheckbox("검정 체크 해제", isOn: $voteOff, style: .vote)
                DesignCheckbox("검정 체크 선택", isOn: $voteOn, style: .vote)
            }
        }
    }
}

/// Toggle 꺼짐·켜짐.
private struct ToggleGallerySection: View {
    @State private var isOff = false
    @State private var isOn = true

    var body: some View {
        GallerySection("Toggle") {
            HStack(spacing: CGFloat.ds.spacing.lg) {
                DesignToggle("꺼짐", isOn: $isOff)
                DesignToggle("켜짐", isOn: $isOn)
            }
        }
    }
}

/// 알약형 칩 둘 가운데 편집 중인 것.
private enum PillField {
    case date
    case time
}

/// Chip 세 꼴. 닫기를 누르면 칩이 사라지고, 알약형은 누르면 편집 중이 바뀐다.
private struct ChipGallerySection: View {
    @State private var outlinedTags = InputGallerySample.tags
    @State private var filledTags = InputGallerySample.tags
    @State private var editing: PillField = .date

    var body: some View {
        GallerySection("Chip") {
            InputGalleryCaption("테두리형 · 닫기 있음 · 닫기 없음")
            HStack(spacing: CGFloat.ds.spacing.sm) {
                ForEach(outlinedTags, id: \.self) { tag in
                    DesignChip(tag, style: .outlined, onClose: { outlinedTags.removeAll { $0 == tag } })
                }
                DesignChip("닫기 없음", style: .outlined)
            }
            InputGalleryCaption("채움형 · 닫기 있음 · 닫기 없음")
            HStack(spacing: CGFloat.ds.spacing.sm) {
                ForEach(filledTags, id: \.self) { tag in
                    DesignChip(tag, style: .filled, onClose: { filledTags.removeAll { $0 == tag } })
                }
                DesignChip("닫기 없음", style: .filled)
            }
            InputGalleryCaption("알약형 · 편집 중 · 편집 중 아님 · 누르면 바뀐다")
            HStack(spacing: CGFloat.ds.spacing.sm) {
                DesignChip("2026.10.05", style: .pill, isEditing: editing == .date) { editing = .date }
                DesignChip("9:41 AM", style: .pill, isEditing: editing == .time) { editing = .time }
            }
            Button("지운 칩 되돌리기") {
                outlinedTags = InputGallerySample.tags
                filledTags = InputGallerySample.tags
            }
        }
    }
}

/// 검색 칸 두 꼴.
private struct SearchGallerySection: View {
    @State private var glassQuery = ""
    @State private var flatQuery = "카페"

    var body: some View {
        GallerySection("검색 칸") {
            InputGalleryCaption("유리 알약형")
            DesignSearchField(text: $glassQuery, placeholder: "장소명으로 검색", style: .glass)
            InputGalleryCaption("납작형 · 글자가 있으면 지우기 버튼")
            DesignSearchField(text: $flatQuery, placeholder: "장소명으로 검색", style: .flat)
        }
    }
}

/// 상태 드롭다운. 접힌 글자색 셋을 나란히 두고, 누르면 iOS 메뉴로 고른다.
private struct StatusMenuGallerySection: View {
    @State private var first: DesignRecruitStatus = .recruiting
    @State private var second: DesignRecruitStatus = .closed
    @State private var third: DesignRecruitStatus = .ended

    var body: some View {
        GallerySection("상태 드롭다운 · 누르면 iOS 메뉴") {
            HStack(spacing: CGFloat.ds.spacing.sm) {
                DesignStatusMenu(status: first) { first = $0 }
                DesignStatusMenu(status: second) { second = $0 }
                DesignStatusMenu(status: third) { third = $0 }
            }
        }
    }
}

/// 입력 화면 안의 작은 설명 글.
private struct InputGalleryCaption: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        DesignText(text, style: TextStyle.ds.caption1.regular, color: Color.ds.text.neutral.tertiary)
    }
}

/// 입력 화면의 견본 값.
private enum InputGallerySample {
    /// 14자. 최대 10자인 한 줄 칸에 넘기면 10자로 잘린다.
    static let longSingleLine = "가나다라마바사아자차카타파하"
    /// 55자. 최대 50자인 여러 줄 칸에 넘기면 「55/50」으로 보인다.
    static let longMultiLine = String(repeating: "가나다라마바사아자차카", count: 5)
    static let tags = ["운동", "독서"]
    static let years = (1950...2010).reversed().map { "\($0)년" }
    static let months = (1...12).map { "\($0)월" }
    static let days = (1...31).map { "\($0)일" }
    static let genders = ["여자", "남자"]
}

#Preview("입력") {
    InputGalleryView()
}
