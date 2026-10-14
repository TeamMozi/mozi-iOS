import SharedDesignSystem
import SwiftUI

/// 입력 화면의 칸 묶음(시안 Form Group)과 줄 구분선. 줄 칸에 글자를 넣을 수 있다.
struct FormGroupGallerySection: View {
    @State private var title = ""
    @State private var intro = ""

    var body: some View {
        GallerySection("칸 묶음 · 줄 구분선") {
            DesignFormGroup {
                DesignTextField(text: $title, placeholder: "모임 이름", maxLength: 30, style: .row)
                    .overlay(alignment: .bottom) {
                        DesignFormRowSeparator()
                    }
                DesignTextArea(
                    text: $intro,
                    placeholder: "모임 소개",
                    maxLength: 100,
                    style: .row(height: FormGroupGallerySample.introHeight, showsCounter: false)
                )
            }
            DesignFormGroup {
                FormGroupGalleryRow(label: "카테고리", value: "영화")
                DesignFormRowSeparator()
                FormGroupGalleryRow(label: "인원", value: "4명")
            }
        }
    }
}

/// 시리즈 설명 그림. 화면 모드를 바꾸면 라이트·다크 그림이 바뀐다.
struct IllustrationGallerySection: View {
    var body: some View {
        GallerySection("그림 · 시리즈 설명") {
            Image.ds.illustration.seriesInfo
        }
    }
}

/// 견본 줄. 왼쪽 라벨, 오른쪽 값, 높이 54 · 좌우 16.
private struct FormGroupGalleryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            DesignText(label, style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.secondary)
            Spacer(minLength: CGFloat.ds.spacing.sm)
            DesignText(value, style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.subtle)
        }
        .padding(.horizontal, CGFloat.ds.spacing.lg)
        .frame(height: FormGroupGallerySample.rowHeight)
    }
}

private enum FormGroupGallerySample {
    static let rowHeight: CGFloat = 54
    static let introHeight: CGFloat = 116
}
