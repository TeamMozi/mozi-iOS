# DemoApp

## 책임
- 데모 앱 「모지 데모」(`com.teamMozi.demo`, scheme `MoziDemo`). 실행은 Debug, 아카이브는 Release
- 디자이너와 iOS 개발자가 서버 없이 화면 모양과 상태를 폰에서 본다
- TestFlight 「모지 데모 팀」 그룹에 올린다 (`fastlane beta app:demo`)

## 현재 상태
- 첫 화면: 이번 빌드에서 바뀐 것 · 흐름 일곱 · 디자인 시스템 · 바닥 글(업로드 빌드만)
- 흐름 일곱 중 로그인만 열린다. 나머지는 「준비 중」
- 로그인 화면 상태 셋: 기본 / 불러오는 중 / 오류 안내
- 디자인 시스템 칸: 색 · 글자 · 버튼 · 화면 상태 네 줄이 화면을 하나씩 연다. 화면마다 위의 전환으로 그 화면만 시스템·다크·라이트로 본다. 시스템 얼럿은 이 전환을 따르지 않고 기기 모드를 따른다
  - 색: 의미 색 63(Figma 묶음 17)
  - 글자: 스타일 21개마다 이름, 수치 한 줄(크기 · 줄 높이 · 자간 % (pt) · 굵기), 여러 줄 견본. 견본 뒤 옅은 가로선이 줄 높이 간격이다
  - 버튼: 공통 버튼 넷 · 소셜 둘
- 기기 설정의 다크·라이트를 따른다. 로그인 화면만 다크로 뜬다
- 떠 있는 데모 버튼: 로그인 화면과 디자인 시스템 화면 넷. 끌어서 옮긴다

## 의존
- 허용: Feature, Domain, SharedDesignSystem, ThirdParty, ThirdPartyUI
- 타깃 둘: 앱 `MoziDemo`(`Sources/`, 화면)와 프레임워크 `MoziDemoKit`(`Kit/`, 테스트가 보는 로직). Kit 는 Feature, Domain, SharedDesignSystem, ThirdParty 만 쓴다. 테스트 `MoziDemoTests` 는 Kit 에만 의존해 앱을 띄우지 않는다
- 금지: Data, Core*, ThirdPartyCore
- `authClient` 는 화면 store 를 만들 때 가짜 응답으로 넣는다. 글꼴은 디자인 시스템이 처음 쓸 때 스스로 등록한다
- 설정 파일은 본 앱 xcconfig 를 그대로 쓴다. Info.plist 에 서버 주소·카카오 키·URL scheme 이 없다

## 내부 규칙
- 데모 때문에 Feature 화면 코드를 고치지 않는다. 필요한 층은 데모 앱이 겹친다
- 화면이나 상태를 더하는 작업은 이 앱 목록에도 한 줄 더한다
  1. 화면: `Kit/Catalog/DemoCatalog.swift` 의 `DemoScreen` 에 케이스를, `DemoFlow.screens` 에 그 화면을 더한다
  2. 상태: `Kit/Screens/<화면>/` 에 `<화면>DemoState` 를 두고 케이스를 더한다 (예: `Kit/Screens/Login/LoginDemoState.swift`)
  3. 상태별 가짜 응답: 같은 폴더의 `<화면>DemoAuthClient` 처럼 Domain `*Client` 를 상태마다 만든다
  4. 겹치는 층: 화면이 위로 올리는 층이 필요하면 `Demo<화면>Feature` 가 Feature 화면과 그 층을 묶는다
  5. 감싸는 화면: `Sources/Screens/<화면>/<화면>DemoScreen` 이 고른 상태로 store 를 만들고 `.demoMenu(...)` 로 데모 버튼을 얹는다 (예: `Sources/Screens/Login/LoginDemoScreen.swift`)
  6. 연결: `Sources/Navigation/DemoRootView.swift` 의 `screenView(_:)` 에 감싸는 화면을 잇는다
  7. 테스트: `Tests/DemoCatalogTests.swift` 의 개수·이름을 고친다
- 테스트가 보는 타입은 `Kit/` 에 두고, 앱이 쓰는 타입과 멤버만 `public` 으로 연다. 화면(View)은 `Sources/` 에 둔다. 테스트는 `@testable import MoziDemoKit` 을 쓴다
- 상태를 고르면 store 와 화면을 처음부터 다시 만든다
- 디자인 시스템 화면을 더하는 작업은 첫 화면 줄 하나와 화면 파일 하나를 더한다
  1. 줄: `Kit/Gallery/GalleryCatalog.swift` 의 `GalleryScreen` 에 케이스와 제목을 더한다. 첫 화면 「디자인 시스템」 칸은 이 순서대로 줄을 그린다
  2. 화면: `Sources/Gallery/<부품>GalleryView.swift` 를 `GalleryPage` 로 감싸 만든다. 제목·모드 전환·바깥 여백은 `GalleryPage`, 구간 제목은 `GallerySection` 이 맡는다 (`Sources/Gallery/GalleryPage.swift`). 모드 값 `GalleryAppearance` 는 `Kit/Gallery/GalleryAppearance.swift` 에 있다
  3. 연결: `Sources/Navigation/DemoRootView.swift` 의 `galleryView(_:)` 에 그 화면을 잇는다
  4. 테스트: `Tests/GalleryCatalogTests.swift` 의 화면 순서를 고친다
- 색·글자·간격은 `Color.ds` · `TextStyle.ds` · `CGFloat.ds` 만 쓴다. 맞는 토큰이 없는 치수는 그 파일 아래 `private enum *Layout` 상수로 둔다

## 빌드 정보
- 업로드 때 fastlane 이 빌드 설정 `MOZI_BUILD_NOTE`(문구 UTF-8 → Base64)와 `MOZI_BUILD_HASH`(커밋 7자리)를 넘긴다
- Info.plist 키 `MoziBuildNote`·`MoziBuildHash` 로 들어오고 `DemoBuildInfo` 가 읽는다. 비어 있거나 풀 수 없으면 개발 빌드다
- 이어가기(`fastlane resume`)는 다시 빌드하지 않는다. 이때 문구를 고쳐 쓰면 앱 안 문구와 알림 문구가 달라진다

## 주요 진입점
- `Sources/MoziDemoApp.swift`
- `Sources/Navigation/DemoRootView.swift`
- `Kit/Catalog/DemoCatalog.swift`
- `Kit/Screens/Login/` · `Sources/Screens/Login/LoginDemoScreen.swift`
- `Sources/DemoMenu/` · `Kit/DemoMenu/DemoFloatingButtonLayout.swift`
- `Sources/Gallery/GalleryPage.swift`
- `Kit/Gallery/GalleryCatalog.swift` · `Kit/Gallery/GalleryAppearance.swift`
- `Sources/Gallery/ColorGalleryView.swift` · `TypographyGalleryView.swift` · `ButtonGalleryView.swift`
- `Kit/BuildInfo/DemoBuildInfo.swift`

## 명령
```bash
xcodebuild -workspace Mozi.xcworkspace -scheme MoziDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.4.1' -skipMacroValidation test
mise exec -- bundle exec fastlane beta app:demo note:"이번 빌드에서 볼 것"
```

## 테스트 포인트
- 빌드 정보: 개발 빌드 판정, Base64 문구 풀기 (`fastlane/test/build_note_test.rb` 와 같은 짝)
- 목록: 흐름 일곱의 순서, 로그인만 열림, 상태 개수와 이름
- 로그인 상태: 기본 1초 뒤 복귀, 불러오는 중 잠김, 오류 안내 얼럿 다시 뜸
- 데모 버튼 끌기 범위
- 디자인 시스템 목록: 화면 넷의 순서(색 · 글자 · 버튼 · 화면 상태), 의미 색 묶음 17개의 순서와 칸 수(합 63), 칸 이름, 글자 스타일 21개, 글자 수치 줄, 모드 전환의 시스템은 덮어쓰지 않음

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
- [Feature](../Feature/README.md)
