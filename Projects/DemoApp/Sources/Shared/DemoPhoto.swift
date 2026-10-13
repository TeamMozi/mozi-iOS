import Foundation

/// 데모 모임의 포스터·프로필 자리에 돌려 쓰는 사진 하나(Figma 시안 포스터 원본, 650×906).
/// `Resources/Photos/demo_photo.png` 는 앱 번들 바로 아래에 들어가고, 화면은 이 파일 URL 을 `AsyncImage` 로 읽는다.
enum DemoPhoto {
    static let url = Bundle.main.url(forResource: "demo_photo", withExtension: "png")
}
