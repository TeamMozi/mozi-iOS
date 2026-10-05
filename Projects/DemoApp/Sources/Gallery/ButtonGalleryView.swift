import SharedDesignSystem
import SwiftUI

/// 버튼 화면. Figma 버튼 묶음 6개 아래에 칸마다 이름, 수치, 기본과 비활성 견본을 보인다.
struct ButtonGalleryView: View {
    var body: some View {
        GalleryPage(.button) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xxl) {
                DesignText(
                    "눌림은 눌러서 본다.",
                    style: TextStyle.ds.caption2.regular,
                    color: Color.ds.text.neutral.tertiary
                )
                buttonsSection
                textButtonSection
                actionSection
                shortcutSection
                pillSection
                loginSection
            }
        }
    }

    private var buttonsSection: some View {
        GallerySection("Buttons") {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ButtonSampleRow(name: "main · sm", metrics: "높이 36 · 여백 12 · 모서리 4 · Headline/SemiBold") {
                    ButtonStatePair {
                        Button("텍스트") {}
                            .buttonStyle(.main)
                    }
                    .controlSize(.small)
                }
                ButtonSampleRow(name: "main · md", metrics: "높이 40 · 여백 16 · 모서리 4") {
                    ButtonStatePair {
                        Button("텍스트") {}
                            .buttonStyle(.main)
                    }
                    .controlSize(.regular)
                }
                ButtonSampleRow(name: "main · lg", metrics: "높이 48 · 여백 20 · 모서리 8") {
                    ButtonStatePair {
                        Button("텍스트") {}
                            .buttonStyle(.main)
                    }
                    .controlSize(.large)
                }
                ButtonSampleRow(name: "neutral · md", metrics: "높이 40 · 여백 16 · 모서리 4") {
                    ButtonStatePair {
                        Button("텍스트") {}
                            .buttonStyle(.neutral)
                    }
                }
                ButtonSampleRow(name: "ghost · md", metrics: "테두리 없음 · 바탕은 화면 바탕과 같음") {
                    ButtonStatePair {
                        Button("텍스트") {}
                            .buttonStyle(.ghost)
                    }
                }
                ButtonSampleRow(name: "main · md · 아이콘", metrics: "아이콘 16 · 간격 8 · 왼쪽") {
                    ButtonStatePair {
                        Button("텍스트", icon: Image.ds.icon.plus.outlined) {}
                            .buttonStyle(.main)
                    }
                }
                ButtonSampleRow(name: "main · lg · 너비 채움", metrics: "내용에 .frame(maxWidth: .infinity)") {
                    Button {} label: {
                        Text("텍스트")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.main)
                    .controlSize(.large)
                }
            }
        }
    }

    private var textButtonSection: some View {
        GallerySection("Text Btn") {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ButtonSampleRow(name: "neutral", metrics: "높이 18 · Caption1/Medium · 아이콘 14 오른쪽") {
                    ButtonStatePair {
                        Button("텍스트 버튼", icon: Image.ds.icon.chevron.right) {}
                            .buttonStyle(.textButton(.neutral))
                    }
                }
                ButtonSampleRow(name: "accent", metrics: "높이 18 · 아이콘 18 오른쪽") {
                    ButtonStatePair {
                        Button("텍스트 버튼") {}
                            .buttonStyle(.textButton(.accent))
                        Button("텍스트 버튼", icon: Image.ds.icon.chevron.right) {}
                            .buttonStyle(.textButton(.accent))
                    }
                }
            }
        }
    }

    private var actionSection: some View {
        GallerySection("action button") {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ButtonSampleRow(name: "accent · neutral · m", metrics: "원 52 · 아이콘 24 · 간격 8") {
                    actionButtons
                }
                ButtonSampleRow(name: "accent · neutral · s", metrics: "원 36 · 아이콘 24 · .controlSize(.small)") {
                    actionButtons
                        .controlSize(.small)
                }
            }
        }
    }

    private var actionButtons: some View {
        ButtonStatePair {
            Button("만들기", icon: Image.ds.icon.heart.outlined) {}
                .buttonStyle(.action(.accent))
            Button("만들기", icon: Image.ds.icon.bookmark.outlined) {}
                .buttonStyle(.action(.neutral))
        }
    }

    private var shortcutSection: some View {
        GallerySection("Shortcut / Circle · Shortcut / Tile") {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ButtonSampleRow(name: "circle", metrics: "48 · 원형 · 활성 / 비활성") {
                    ButtonStatePair {
                        Button("알림", icon: Image.ds.icon.bell.outlined) {}
                            .buttonStyle(.shortcut(.circle))
                    }
                }
                ButtonSampleRow(name: "tile", metrics: "44 · 모서리 12 · 활성 / 비활성") {
                    ButtonStatePair {
                        Button("설정", icon: Image.ds.icon.setting.outlined) {}
                            .buttonStyle(.shortcut(.tile))
                    }
                }
            }
        }
    }

    private var pillSection: some View {
        GallerySection("btn_text") {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ButtonSampleRow(name: "pill", metrics: "높이 32 · 여백 12 · 시스템 유리 효과") {
                    ButtonStatePair {
                        Button("정보") {}
                            .buttonStyle(.pill)
                    }
                }
            }
        }
    }

    private var loginSection: some View {
        GallerySection("login") {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                ButtonSampleRow(name: "kakao · apple", metrics: "높이 48 · 모서리 8 · 간격 8 · 너비 채움") {
                    VStack(spacing: CGFloat.ds.spacing.sm) {
                        SocialLoginButton(.kakao) {}
                        SocialLoginButton(.apple) {}
                    }
                }
            }
        }
    }
}

/// 칸 하나. 이름과 수치 아래에 견본을 놓는다.
private struct ButtonSampleRow<Content: View>: View {
    let name: String
    let metrics: String
    private let content: Content

    init(name: String, metrics: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.metrics = metrics
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
                DesignText(name, style: TextStyle.ds.caption1.semiBold, color: Color.ds.text.neutral.secondary)
                DesignText(metrics, style: TextStyle.ds.caption2.regular, color: Color.ds.text.neutral.tertiary)
            }
            content
        }
    }
}

/// 같은 버튼을 한 줄에 기본, 비활성 순으로 놓는다.
private struct ButtonStatePair<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: CGFloat.ds.spacing.sm) {
            content
            content
                .disabled(true)
        }
    }
}

#Preview("버튼") {
    ButtonGalleryView()
}
