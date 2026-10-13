# DemoApp

## 책임
- 데모 앱 「모지 데모」(`com.teamMozi.demo`, scheme `MoziDemo`). 실행은 Debug, 아카이브는 Release
- 디자이너와 iOS 개발자가 서버 없이 화면 모양과 상태를 폰에서 본다
- TestFlight 「모지 데모 팀」 그룹에 올린다 (`fastlane beta app:demo`)

## 현재 상태
- 첫 화면: 이번 빌드에서 바뀐 것 · 흐름 여덟 · 디자인 시스템 · 바닥 글(업로드 빌드만)
- 흐름 여덟 중 로그인 · 온보딩 · 숏폼 · 모임이 열린다. 나머지는 「준비 중」. 모임 흐름은 「모임 상세」 · 「위젯 / 스냅포인트」 두 화면. 위젯 데모는 두 상태(알림 전 · 진행 중) 모두 모임이 모집 마감으로 시작한다(`MeetingDetailDemoBackend(initialStatus:)`). 모집 중이면 「모임 종료」 가 감춰지기 때문이다. 모임 상세 데모는 모집 중으로 시작한다
- 모임 데모는 사진 하나(`Resources/Photos/demo_photo.png`, 시안 포스터 원본)를 모임 포스터·회차 카드 포스터·모임장·멤버·알림 요청자·「나」 의 프로필 사진에 돌려 쓴다. 앱이 `Bundle.main` 에서 파일 URL 을 찾아 가짜 서버(`MeetingDetailDemoBackend(photoURL:)`)와 시리즈 Client(`MeetingDetailDemoClients.seriesClient(photoURL:)`)에 넘긴다. Domain 가짜 데이터는 사진이 없다
- 로그인 화면 상태 셋: 기본 / 불러오는 중 / 오류 안내
- 숏폼 「탭 안 이동」: 누르면 숏폼 탭 Flow 가 전체 화면으로 덮여 뜬다. 상태 셋: 첫 화면 / 견본 1장 / 견본 2장. 견본의 「다음」은 견본을 하나 더 쌓고, 뒤로 가기로 하나씩 빠진다
- 온보딩 세 화면은 모두 전체 화면으로 덮여 뜬다. 프로필 설정 상태 셋: 빈 화면 / 다 채운 화면 / 로그아웃 실패(뒤로는 데모에 Flow 가 없어 아무 일도 없다). 카테고리 설정 상태 여섯: 받는 중 / 기본 / 고른 상태 / 저장 중 / 받기 실패 / 저장 실패. 온보딩 흐름 전체 상태 하나(처음부터): 가짜 목록과 1초 뒤 성공하는 저장으로 「완료」 까지 넘기고, 끝나거나 로그아웃하면 `DemoOnboardingFlowFeature` 가 처음 화면으로 되돌린다
- 디자인 시스템 칸: 색 · 글자 · 버튼 · 화면 상태 · 입력 · 헤더·탭바 여섯 줄이 화면을 하나씩 연다. 화면마다 위의 전환으로 그 화면만 시스템·다크·라이트로 본다. 시스템 얼럿은 이 전환을 따르지 않고 기기 모드를 따른다
  - 색: 의미 색 66(Figma 묶음 17 + 알파 색 `overlay/gray/10` + 상태 글자색 `text/status` 둘)
  - 글자: 스타일 21개마다 이름, 수치 한 줄(크기 · 줄 높이 · 자간 % (pt) · 굵기), 여러 줄 견본. 견본 뒤 옅은 가로선이 줄 높이 간격이다
  - 버튼: 버튼 여섯 계열(기본 · 글자 · 액션 · Shortcut · 알약 · 소셜)을 기본 줄과 비활성 줄로 늘어놓는다. 기본 버튼은 sm·md·lg, 아이콘, 너비 채움 예를 보인다. 눌림은 눌러서 본다
  - 입력: 한 줄 · 여러 줄 · 캡션 · 드롭다운 줄 · 체크박스 세 꼴 · 토글 · 칩 세 꼴 · 검색 칸 두 꼴 · 상태 드롭다운을 시안 상태별로 늘어놓는다. 글자 입력과 글자 수 끊기, 체크, 토글, 칩 닫기와 편집 중, 상태 메뉴, 드롭다운 메뉴가 실제로 동작한다
  - 헤더·탭바: 하단 버튼 영역 다섯(Figma 변형 순서). 헤더 · 탭바 · 바텀시트는 버튼을 누르면 고른 모드로 전체 화면 견본이 뜬다. 헤더는 변형 다섯(투명 · 채움 · 글자 버튼 · 오른쪽 버튼 둘 · 왼쪽 정렬 제목), 바텀시트는 기본 · 왼쪽 정렬 제목 × large · medium, 탭바는 탭 안에서 하단 버튼 영역이 있는 화면을 연다
- 처음엔 기기 설정의 다크·라이트를 따른다. 로그인 화면은 화면이 스스로 다크를 고른다. 온보딩 세 화면, 숏폼, 모임 두 화면은 스스로 고르지 않아 기기 설정이나 시트에서 고른 화면 모드를 따른다
- 떠 있는 데모 버튼: 로그인 화면, 온보딩 세 화면, 숏폼 「탭 안 이동」, 모임 「모임 상세」 · 「위젯 / 스냅포인트」, 디자인 시스템 화면 여섯. 끌어서 옮긴다. 누르면 시트에 「목록으로 돌아가기」, 「화면 모드」(시스템 · 다크 · 라이트, 로그인·디자인 시스템 화면은 없음), 상태가 있으면 「화면 상태」 목록이 뜬다
  - 버튼과 시트는 앱 창 위의 별도 창(`Kit/DemoMenu/DemoMenuPassThroughWindow.swift`, 창 높이 `.normal + 1`)에 그린다. 화면 데모가 띄운 덮개·시트(모임 상세의 사이드바 등) 위에 뜨고, 버튼 밖 터치는 아래 앱 창으로 넘긴다
  - 화면 모드는 앱 창(데모 버튼 창이 아닌 `.normal` 높이 창, `DemoMenuPassThroughWindow.appWindow(among:)`)의 `overrideUserInterfaceStyle` 에 건다. 그래서 전체 화면으로 덮어 띄운 화면과 그 안에서 이미 떠 있는 시트·덮개(모임 상세의 사이드바 등)도 바로 바뀐다. 시스템은 기기 모드를 덮어쓰지 않는다(`.unspecified`)
  - 화면 데모를 닫으면(「목록으로 돌아가기」, 데모 버튼 창 보관 객체가 풀릴 때) 앱 창을 시스템으로 되돌린다. 기억하지 않아 화면 데모를 새로 열면 시스템이다
  - 로그인 화면은 스스로 다크를 고르고, 디자인 시스템 화면은 자기 모드 전환이 있어 시트에 화면 모드를 두지 않는다 (`demoMenu(selectsAppearance: false)`, 로그인은 `DemoScreen.selectsAppearance`). 이 화면들은 앱 창 모드를 건드리지 않는다

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
- 자기 NavigationStack 을 가진 Feature Flow 를 띄우는 화면은 `DemoScreen.presentsFullScreen` 을 참으로 둔다. `DemoRootView` 가 최상위 NavigationStack 에 쌓지 않고 전체 화면으로 덮어 띄운다. 겹치면 뒤로 가기가 꼬인다
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
- `Kit/Screens/TabNavigation/` · `Sources/Screens/TabNavigation/TabNavigationDemoScreen.swift`
- `Kit/Screens/ProfileSetting/` · `Kit/Screens/InterestSetting/` · `Kit/Screens/OnboardingFlow/` · `Sources/Screens/{ProfileSetting,InterestSetting,OnboardingFlow}/`
- `Sources/DemoMenu/` · `Kit/DemoMenu/DemoFloatingButtonLayout.swift` · `Kit/DemoMenu/DemoMenuAppearance.swift` · `Kit/DemoMenu/DemoMenuPassThroughWindow.swift`
- `Sources/Gallery/GalleryPage.swift`
- `Kit/Gallery/GalleryCatalog.swift` · `Kit/Gallery/GalleryAppearance.swift`
- `Sources/Gallery/ColorGalleryView.swift` · `TypographyGalleryView.swift` · `ButtonGalleryView.swift` · `InputGalleryView.swift` · `FramePartsGalleryView.swift`
- `Sources/Gallery/FrameParts/` (헤더·탭바 전체 화면 견본) · `Kit/Gallery/FramePartsCatalog.swift`
- `Kit/BuildInfo/DemoBuildInfo.swift`

## 명령
```bash
xcodebuild -workspace Mozi.xcworkspace -scheme MoziDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.4.1' -skipMacroValidation test
mise exec -- bundle exec fastlane beta app:demo note:"이번 빌드에서 볼 것"
```

## 테스트 포인트
- 빌드 정보: 개발 빌드 판정, Base64 문구 풀기 (`fastlane/test/build_note_test.rb` 와 같은 짝)
- 목록: 흐름 여덟의 순서, 로그인 · 온보딩 · 숏폼 · 모임만 열림, 상태 개수와 이름, 전체 화면으로 띄우는 화면
- 온보딩 상태: 프로필 다 채움의 「시작하기」 켜짐, 로그아웃 실패 알림, 카테고리 고른 세 칸·저장 중 모양·받기 실패·저장 실패 알림 다시 뜸, 흐름 데모가 끝·로그아웃 때 처음으로 돌아감
- 로그인 상태: 기본 1초 뒤 복귀, 불러오는 중 잠김, 오류 안내 얼럿 다시 뜸
- 탭 안 이동 상태: 상태마다 쌓인 견본 수와 1부터 매긴 번호
- 데모 버튼 끌기 범위, 데모 버튼 창의 높이와 버튼 밖 터치 넘기기
- 디자인 시스템 목록: 화면 여섯의 순서(색 · 글자 · 버튼 · 화면 상태 · 입력 · 헤더·탭바), 의미 색 묶음 18개의 순서와 칸 수(합 66), 칸 이름, 글자 스타일 21개, 글자 수치 줄, 모드 전환의 시스템은 덮어쓰지 않음
- 헤더·탭바 견본: 하단 버튼 영역 다섯의 이름·배치·위쪽 선, 전체 화면 견본 셋, 헤더 변형 다섯과 배경, 바텀시트 넷의 제목·높이·제목 자리

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
- [Feature](../Feature/README.md)
