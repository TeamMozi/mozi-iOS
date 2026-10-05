import SharedDesignSystem
import SwiftUI

/// 탭바 견본. 탭 허브와 같은 꾸밈이다: 디자인 시스템 아이콘, 선택 시 채움, 노란 「+」.
/// 탭 안에서 하단 버튼 영역이 있는 화면을 열면 탭바가 숨는다.
struct TabBarSampleScreen: View {
    let onClose: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var selection: TabBarIcon = .playStack

    var body: some View {
        TabView(selection: $selection) {
            ForEach(TabBarIcon.allCases, id: \.self) { icon in
                TabBarSamplePage(title: Self.title(of: icon), onClose: onClose)
                    .tabItem {
                        icon.image(isSelected: selection == icon, colorScheme: colorScheme)
                    }
                    .tag(icon)
            }
        }
    }

    private static func title(of icon: TabBarIcon) -> String {
        switch icon {
        case .playStack: "숏폼"
        case .search: "검색"
        case .chat: "채팅"
        case .person: "마이"
        case .plus: "만들기"
        }
    }
}

/// 탭 하나의 화면. 헤더와, 하단 버튼 영역이 있는 화면으로 가는 줄 하나.
private struct TabBarSamplePage: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CGFloat.ds.spacing.md) {
                    NavigationLink {
                        BottomButtonAreaScreenSample()
                    } label: {
                        FrameSampleRow(title: "하단 버튼 영역이 있는 화면")
                    }
                    .buttonStyle(.plain)
                }
                .padding(CGFloat.ds.layout.margin)
            }
            .background(Color.ds.fill.neutral.default.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    FrameSampleIconButton(image: Image.ds.icon.close.outlined, label: "닫기", action: onClose)
                }
                ToolbarItem(placement: .principal) {
                    DesignToolbarTitle(title)
                }
            }
        }
    }
}

/// 탭 안에서 쌓인 화면. 하단 버튼 영역을 붙여 탭바가 숨는다.
/// 입력 칸을 눌러 키보드를 올리면 버튼 줄이 키보드 뒤에 남는다.
private struct BottomButtonAreaScreenSample: View {
    @State private var text = ""

    var body: some View {
        ScrollView {
            TextField("입력해 보세요", text: $text)
                .font(TextStyle.ds.body.regular.font)
                .foregroundStyle(Color.ds.text.neutral.primary)
                .padding(CGFloat.ds.spacing.md)
                .background(
                    Color.ds.fill.neutral.subtle,
                    in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._8, style: .continuous)
                )
                .padding(CGFloat.ds.layout.margin)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("하단 버튼 영역")
            }
        }
        .bottomButtonArea {
            BottomButtonArea(.single) {
                Button {} label: {
                    Text("신청하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.main)
                .controlSize(.large)
            }
        }
    }
}
