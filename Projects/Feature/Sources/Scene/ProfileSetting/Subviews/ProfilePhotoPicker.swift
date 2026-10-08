import PhotosUI
import SharedDesignSystem
import SwiftUI

/// 원형 프로필 사진과 오른쪽 아래 카메라 버튼. 고른 사진은 `onPick` 으로 올리고, 그리는 사진은 쓰는 쪽이 넘긴다.
struct ProfilePhotoPicker: View {
    let photoData: Data?
    let onPick: (Data) -> Void

    @State private var selection: PhotosPickerItem?

    var body: some View {
        photo
            .frame(width: ProfilePhotoLayout.photoSize, height: ProfilePhotoLayout.photoSize)
            .background(Color.ds.fill.neutral.strong)
            .clipShape(Circle())
            .overlay(alignment: .bottomTrailing) {
                PhotosPicker(selection: $selection, matching: .images) {
                    Image.ds.icon.camera.filled
                        .iconSize(ProfilePhotoLayout.cameraIconSize)
                        .foregroundStyle(Color.ds.text.neutral.primary)
                        .frame(width: ProfilePhotoLayout.cameraButtonSize, height: ProfilePhotoLayout.cameraButtonSize)
                        .background(Color.ds.fill.neutral.default, in: Circle())
                        .overlay {
                            // 시안 테두리는 원 바깥쪽에 그린다
                            Circle()
                                .inset(by: -ProfilePhotoLayout.cameraBorderWidth / 2)
                                .stroke(Color.ds.border.neutral._20, lineWidth: ProfilePhotoLayout.cameraBorderWidth)
                        }
                }
                .accessibilityLabel("프로필 사진 고르기")
                .padding(.trailing, ProfilePhotoLayout.cameraTrailingInset)
            }
            .onChange(of: selection) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        onPick(data)
                    }
                    // 같은 사진을 다시 골라도 바뀌도록 비운다
                    selection = nil
                }
            }
    }

    @ViewBuilder
    private var photo: some View {
        if let photoData, let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image.ds.onboarding.profileDefault
                .resizable()
                .scaledToFill()
                .overlay(ProfilePhotoLayout.defaultDim)
        }
    }
}

private enum ProfilePhotoLayout {
    static let photoSize: CGFloat = 120
    static let cameraButtonSize: CGFloat = 36
    static let cameraIconSize = CGFloat.ds.iconSize._28
    static let cameraBorderWidth: CGFloat = 0.6
    /// 카메라 버튼 오른쪽 끝 ~ 사진 오른쪽 끝(120 - 79 - 36). 아래 끝은 사진과 맞닿는다
    static let cameraTrailingInset: CGFloat = 5
    /// 시안 `Dim` 은 두 모드 모두 검정 40%(`overlay/dark/40`)다. 디자인 시스템이 이 원색을 열지 않아 값으로 둔다
    static let defaultDim = Color.black.opacity(0.4)
}
