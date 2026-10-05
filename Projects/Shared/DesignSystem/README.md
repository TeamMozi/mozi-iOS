# SharedDesignSystem

## 책임
- Figma 파일 `hnGl2AWCk8XCvrNK7MBkvq` 의 색·숫자·글자 스타일을 코드 토큰으로 연다
- 공통 부품: 버튼 여섯 계열(스타일 `.main`·`.neutral`·`.ghost`·`.textButton(_:)`·`.action(_:)`·`.shortcut(_:)`·`.pill` 과 화면 조각 `SocialLoginButton`), 아이콘 버튼 생성자 `Button(_:icon:)`, `DesignText`, `ScreenStatus` · `.screenStatus`, 하단 버튼 영역 `BottomButtonArea`
- 입력 부품: `DesignTextField` · `DesignTextArea` · `DesignDropdownRow` · `DesignCheckbox` · `DesignToggle` · `DesignChip` · `DesignSearchField` · `DesignStatusMenu`
- 헤더·탭바 꾸밈: 탭바 아이콘 `TabBarIcon`, 툴바 제목·아이콘 `DesignToolbarTitle`·`DesignToolbarIcon`, 헤더 배경 `.designHeaderBackground(_:)`, 뒤로 가기 그림 `DesignNavigationBar.applyBackIndicator()`, 시트 딤 `.designSheet(item:detents:content:)`
- 글꼴(Pretendard 네 굵기)과 에셋(로고·소셜 아이콘·로그인 숏폼 사진)

## 의존
- 허용: SharedUtils
- Feature·DemoApp 은 `Color.ds` · `CGFloat.ds` · `TextStyle.ds` · `Image.ds` 와 공통 부품만 쓴다

## 이름 규칙
Figma 경로를 낱말 단위로 옮긴다.

- `/` 는 `.` 이 된다
- 공백·하이픈으로 이은 낱말은 camelCase 로 잇는다: `Button Height/control-sm` → `CGFloat.ds.buttonHeight.controlSm`
- 숫자로 시작하면 `_` 를 붙인다: `border/neutral/10` → `Color.ds.border.neutral._10`
- Swift 예약어는 선언에서 백틱으로 감싼다: `fill/neutral/default` → 쓸 때 `Color.ds.fill.neutral.default`
- 글자 스타일: `Title2/SemiBold` → `TextStyle.ds.title2.semiBold`
- 타입을 중첩하지 않는다. 묶음마다 평평한 struct 를 두고 프로퍼티로 잇는다

## Figma 대응
| Figma | 코드 | 개수 | 공개 |
|---|---|---|---|
| `color/*` 원시 색 | `PrimitiveColor.primary._100` | 34 | 모듈 안 |
| `Sementic Numbers` 컬렉션의 `overlay/dark·light·gray/*` 알파 색 | `AlphaColor.overlay.dark._40` | 20 | 모듈 안 |
| 의미 색 `text` · `fill` · `border` · `button` · `overlay` | `Color.ds.text.neutral.primary` (쌍은 `SemanticColor.text.neutral.primary`) | 63 | `Color.ds` |
| `radius` · `spacing` · `border` · `Button Height` · `icon-size` | `CGFloat.ds.radius._8`, `CGFloat.ds.spacing.lg`, `CGFloat.ds.iconSize._14` | 24 | `CGFloat.ds` |
| 그리드 스타일 `mozi_layout` 의 바깥 여백 16 | `CGFloat.ds.layout.margin` | 1 | `CGFloat.ds` |
| 글자 스타일 (Pretendard) | `TextStyle.ds.caption1.medium` | 21 | `TextStyle.ds` |

그리드의 열 수(4)와 열 간격(16)은 옮기지 않았다. SwiftUI 배치에 쓰지 않는다.

## 모드
- 의미 색은 다크·라이트 원시 색 쌍(`ThemedColor`)이다. 두 값은 Figma 별칭을 그대로 옮겼다
- `Color.ds` 의 의미 색은 기기 모드를 따라 바뀐다. 모드가 정해지지 않은 trait 에서는 다크 값이다
- 앱과 데모 앱은 기기 설정만 따른다. 로그인 화면만 `.preferredColorScheme(.dark)` 로 다크다

## Figma 밖 토큰
- `Color.ds.social.*` 넷만 있다. 모드와 상관없다. 바탕은 카카오·애플 브랜드 색이고, 글자·아이콘은 Figma login 의 `color/neutral/1200` 이다
  - `kakao` #FEE500 · `kakaoContent` #0E0E11 · `appleBackground` #FFFFFF · `appleContent` #0E0E11
- 이전의 Secondary 색 9개, System orange, `CGFloat.ds.dim`, `Font.ds` 는 지웠다

## Figma 와 맞춰 볼 것
- `overlay/gray/40`·`overlay/gray/80` 은 다른 gray(#AFAFAF)와 RGB 가 다르다(#706D82·#423F55). 이름과 지금 값(40%·80%)을 그대로 둔다. Figma 값(20%)은 디자이너가 맞춘다
- 흰색 알파 색은 `overlay/light/80`(0xCC)이다. 의미 색 `overlay/dim/70` 의 라이트 값이 이것을 가리킨다
- 의미 색 가운데 system·swatch 원시 색을 가리키는 것이 없다. 오류·성공 색이 필요하면 Figma 에 의미 색이 먼저 있어야 한다

## 부품
버튼은 SwiftUI `Button` 에 스타일을 입혀 쓴다. 크기는 `.controlSize`, 비활성은 `.disabled()`, 너비 채우기는 내용에 `.frame(maxWidth: .infinity)` 를 건다.

```swift
Button("다음") {}
    .buttonStyle(.main)
    .controlSize(.large)

Button {
    store.send(.logoutTapped)
} label: {
    Text("로그아웃")
        .frame(maxWidth: .infinity)
}
.buttonStyle(.ghost)
.controlSize(.large)
.disabled(store.isLoggingOut)

Button("전체 보기", icon: Image.ds.icon.chevron.right) {}
    .buttonStyle(.textButton(.accent))

SocialLoginButton(.kakao) {
    store.send(.kakaoLoginTapped)
}
```

| 계열 | 쓰는 법 | Figma | 크기 | 눌림 | 비활성 |
|---|---|---|---|---|---|
| 기본 | `.main` · `.neutral` · `.ghost` | Buttons | `.mini`·`.small` → sm 36, `.regular` → md 40, `.large`·`.extraLarge` → lg 48 | Figma Pressed 색 | Figma Disabled 색 |
| 글자 | `.textButton(.neutral)` · `.textButton(.accent)` | Text Btn | 하나 (높이 18) | 불투명도 0.88 | 모양 그대로 |
| 액션 | `.action(.accent)` · `.action(.neutral)` | action button | `.small` 이하 → s (원 36), `.regular` 이상 → m (원 52) | 불투명도 0.88 | 모양 그대로 |
| Shortcut | `.shortcut(.circle)` · `.shortcut(.tile)` | Shortcut / Circle · Tile | 하나 (48 · 44) | 불투명도 0.88 | Figma Disabled 색 |
| 알약 글자 | `.pill` | btn_text | 하나 (높이 32) | 시스템 유리 반응 | 유리 효과 없이 `text/neutral/subtle` 글자 |
| 소셜 | `SocialLoginButton(.kakao)` · `SocialLoginButton(.apple)` | login | 하나 (높이 48, 너비 채움) | 불투명도 0.88 | 모양 그대로 |

- 아이콘은 `Button(_:icon:)` 로 넘긴다. 스타일이 아이콘 크기와 간격을 정한다. 기본 버튼은 글자 왼쪽, 글자 버튼은 오른쪽, 액션 버튼은 원 안에 둔다. Shortcut 은 아이콘만 그리고 제목은 VoiceOver 가 읽는다
- 스타일만 쓰는 자리: `NavigationLink`·`ShareLink`·`Menu` 등 `.buttonStyle()` 을 받는 곳. 화면 조각은 `SocialLoginButton` 하나다
- 기본 버튼 글자는 세 크기 모두 `headline.semiBold` 다. ghost 는 테두리가 없다
- 버튼 글자는 높이가 고정이라 줄 간격 여백을 걸지 않는다
- 토큰이 없는 값(아이콘 16, 여백 20, 액션 accent 의 원시 색 `color/primary/50`·`color/neutral/1300` 등)은 부품 파일 안 상수다
- 글자는 `DesignText(_:style:)` 로 쓴다. `style.font` 만 꺼내면 줄 높이·자간이 빠진다
- 입력 부품은 값과 선택을 들고 있지 않는다. 쓰는 쪽이 바인딩이나 지금 값과 「누르면 할 일」을 넘긴다. 오류·비활성 상태는 없다
- 한 줄 `DesignTextField` 와 여러 줄·캡션 `DesignTextArea`(`.standard`·`.caption`)는 UIKit `UITextField`·`UITextView` 를 감싼다. 보이는 글자 하나를 1자로 세고 최대를 넘는 입력은 받지 않는다(붙여넣은 글은 뒤가 잘린다). 조합 중인 글자도 글자 수와 쓰는 쪽 값에 들어가지만, 조합 중에는 자르지 않고 조합이 끝나면 넘친 만큼 자른다
- 최대보다 긴 값이 넘어오면 한 줄 칸은 받자마자 잘라 쓰는 쪽 값도 바꾸고, 여러 줄·캡션 칸은 그대로 두고 「55/50」으로 보이며 지우기만 받는다. 「현재/최대」는 여러 줄·캡션 칸만 그린다
- 입력 중 테두리는 칸이 키보드를 가진 동안 켜진다
- 드롭다운 줄 칸(`DesignDropdownCell`)은 지금 값·메뉴 항목·`onSelect` 를 받는다. 누르면 칸 안의 iOS 기본 `Menu` 가 뜨고 지금 값에 체크가 붙는다. 메뉴가 떠 있어도 입력 중 테두리는 켜지지 않는다
- 체크박스 `.check`·`.order(Int)`·`.vote`, 칩 `.outlined`·`.filled`(닫기 아이콘 켜고 끔)·`.pill`(편집 중), 검색 칸 `.glass`(`glassEffect`)·`.flat`(지우기 버튼), 상태 드롭다운은 iOS 기본 `Menu` 와 표시용 `DesignRecruitStatus` 셋(Domain 타입과 다르다)
- 체크박스·토글은 VoiceOver 이름(`title`)을 받고 화면에는 그리지 않는다
- 원시 색은 부품 안에서만 쓴다: 토글 켜짐 green, 상태 「모집 마감」·필수 `*` red, 체크박스·칩 채움형의 neutral·primary 원시 색, 번호 체크박스 해제 바탕 알파 `overlay/gray/70`. Figma 에 의미 색이 생기면 옮긴다
- 포커스: 쓰는 화면이 칸에 `.focused($focus, equals:)` 를 건다. 감싼 UIKit 칸과 양방향으로 이어진다(테스트 `DesignTextInputFocusTests`)
- 탭바·헤더·바텀시트 헤더는 iOS 26 시스템 부품(`TabView`, `NavigationStack` + `.toolbar`, `.sheet` 안 `NavigationStack` + `.toolbar`)이다. 디자인 시스템은 꾸밈만 준다
  - 탭 아이콘: `.tabItem { TabBarIcon.search.image(isSelected:colorScheme:) }`. 선택은 채움, 나머지는 선, 「+」 는 늘 채움 + `text/accent/default`. 색을 입힌 원본 그림이라 탭바에 `.tint` 를 걸지 않는다
  - 툴바: 제목 `DesignToolbarTitle`(Medium 16), 아이콘 `DesignToolbarIcon`(24) 둘 다 `text/neutral/primary`. 오른쪽 버튼 둘은 `ToolbarItem` 둘 + `ToolbarSpacer(.fixed)`, 왼쪽 정렬 제목은 `.topBarLeading` + `.sharedBackgroundVisibility(.hidden)` + `.fixedSize()`
  - 헤더 배경: `.transparent`(시스템 기본, 스크롤하면 가장자리 효과) · `.filled`(`fill/neutral/default`)
  - 뒤로 가기: 시스템 버튼에 그림만 `chevron.left`. 앱·데모 앱 시작에서 `DesignNavigationBar.applyBackIndicator()` 를 한 번 부른다
  - 바텀시트: `.designSheet(item:detents:content:)`(또는 `isPresented:`)로 띄운다. 시스템 딤을 끄고 뒤 화면 전체를 `overlay/gray/default` 로 덮으며, 딤을 누르면 닫힌다. 딤 짙기는 시트 위치를 따른다(자리 잡으면 다 짙고, 가장 작은 높이 아래로 끌어내린 만큼 옅어진다). 몸통은 `fill/neutral/default`. 높이는 쓰는 화면이 `detents` 로 작은 것부터 넘긴다(`.large` 가 없으면 마지막을 가장 큰 높이로 본다)
- 하단 버튼 영역 `BottomButtonArea(_:showsTopBorder:caption:buttons:)`: 배치 `.single` · `.split5To5` · `.split3To7`(오른쪽 240 고정). 여백 위 12(3:7 은 16)·좌우 16, 간격 12, 바탕 `fill/neutral/default`, 위쪽 1pt 선 `border/neutral/10` 은 켜고 끈다. 아래 여백은 안전 영역이다. 버튼과 윗줄은 쓰는 화면이 넣는다
  - 화면에 붙일 때는 `.bottomButtonArea { BottomButtonArea(...) { ... } }`. 탭바를 숨기고, 키보드가 올라와도 버튼 줄은 키보드 뒤에 남는다. 본문은 그대로 키보드를 피한다

## 글꼴
- `TextStyle.font` 가 처음 불릴 때 Tuist 생성 `SharedDesignSystemFontFamily.registerAllCustomFonts()` 를 한 번 부른다
- 앱·미리보기·테스트는 글꼴을 따로 등록하지 않는다

## 아이콘 대응표
Figma 아이콘 이름과 코드 경로. 아이콘 경로는 `Image.ds.icon.<종류>.<모양>`, 크기는 `.iconSize(_:)`, 색은 `.foregroundStyle` 이다. `Image.ds` 는 장식용이라 VoiceOver 가 읽지 않는다.

기존 7장:

| 코드 경로 | Tuist 접근자 | 에셋 |
|---|---|---|
| `Image.ds.brand.logo` | `logoMozi` | `Brand/logo_mozi` |
| `Image.ds.login.shortform01` | `loginShortform01` | `Login/login_shortform_01` |
| `Image.ds.login.shortform02` | `loginShortform02` | `Login/login_shortform_02` |
| `Image.ds.login.shortform03` | `loginShortform03` | `Login/login_shortform_03` |
| `Image.ds.login.shortform04` | `loginShortform04` | `Login/login_shortform_04` |
| `Image.ds.social.apple` | `iconSocialApple` | `Icon/Social/icon_social_apple` |
| `Image.ds.social.kakao` | `iconSocialKakao` | `Icon/Social/icon_social_kakao` |

아이콘 168장:

| 코드 경로 | 에셋 이름 | Figma 종류 · 변형 | 노드 | 비고 |
|---|---|---|---|---|
| `Image.ds.icon.arrows.down` | `icon_arrows_down` | `icon/arrows` · `Type=Down` | `53:3965` |  |
| `Image.ds.icon.arrows.left` | `icon_arrows_left` | `icon/arrows` · `Type=Left` | `53:3980` |  |
| `Image.ds.icon.arrows.leftDown` | `icon_arrows_left_down` | `icon/arrows` · `Type=Left-Down` | `53:3995` |  |
| `Image.ds.icon.arrows.leftUp` | `icon_arrows_left_up` | `icon/arrows` · `Type=Left-Up` | `53:3985` |  |
| `Image.ds.icon.arrows.right` | `icon_arrows_right` | `icon/arrows` · `Type=Right` | `53:3975` |  |
| `Image.ds.icon.arrows.rightDown` | `icon_arrows_right_down` | `icon/arrows` · `Type=Right-Down` | `53:4000` |  |
| `Image.ds.icon.arrows.rightUp` | `icon_arrows_right_up` | `icon/arrows` · `Type=Right-Up` | `53:3990` |  |
| `Image.ds.icon.arrows.up` | `icon_arrows_up` | `icon/arrows` · `Type=UP` | `53:3970` |  |
| `Image.ds.icon.backspace.filled` | `icon_backspace_filled` | `icon/backspace` · `Style=filled` | `346:11891` |  |
| `Image.ds.icon.backspace.outlined` | `icon_backspace_outlined` | `icon/backspace` · `Style=outlined` | `346:11901` |  |
| `Image.ds.icon.bell.filled` | `icon_bell_filled` | `icon/bell` · `Style=filled` | `53:2869` |  |
| `Image.ds.icon.bell.outlined` | `icon_bell_outlined` | `icon/bell` · `Style=outlined` | `53:2871` |  |
| `Image.ds.icon.bellOff.filled` | `icon_bell_off_filled` | `icon/bell-off` · `Style=filled` | `53:2877` |  |
| `Image.ds.icon.bellOff.outlined` | `icon_bell_off_outlined` | `icon/bell-off` · `Style=outlined` | `53:2879` |  |
| `Image.ds.icon.bookmark.filled` | `icon_bookmark_filled` | `icon/bookmark` · `Style=filled` | `53:2864` |  |
| `Image.ds.icon.bookmark.outlined` | `icon_bookmark_outlined` | `icon/bookmark` · `Style=outlined` | `53:2866` |  |
| `Image.ds.icon.calendar.filled` | `icon_calendar_filled` | `icon/calendar` · `Style=filled` | `53:3009` | 채움·선 같은 그림 |
| `Image.ds.icon.calendar.outlined` | `icon_calendar_outlined` | `icon/calendar` · `Style=outlined` | `53:3011` | 채움·선 같은 그림 |
| `Image.ds.icon.camera.filled` | `icon_camera_filled` | `icon/camera` · `Style=filled` | `53:3044` |  |
| `Image.ds.icon.camera.outlined` | `icon_camera_outlined` | `icon/camera` · `Style=outlined` | `53:3046` |  |
| `Image.ds.icon.chat.filled` | `icon_chat_filled` | `icon/chat` · `Style=filled` | `53:3305` |  |
| `Image.ds.icon.chat.outlined` | `icon_chat_outlined` | `icon/chat` · `Style=outlined` | `53:3307` |  |
| `Image.ds.icon.check.filled` | `icon_check_filled` | `icon/check` · `Style=filled` | `53:3151` |  |
| `Image.ds.icon.check.outlined` | `icon_check_outlined` | `icon/check` · `Style=outlined` | `53:3153` |  |
| `Image.ds.icon.chevron.down` | `icon_chevron_down` | `icon/chevron` · `Type=down` | `53:3950` |  |
| `Image.ds.icon.chevron.left` | `icon_chevron_left` | `icon/chevron` · `Type=left` | `53:3955` |  |
| `Image.ds.icon.chevron.right` | `icon_chevron_right` | `icon/chevron` · `Type=right` | `53:3960` |  |
| `Image.ds.icon.chevron.up` | `icon_chevron_up` | `icon/chevron` · `Type=up` | `53:3945` |  |
| `Image.ds.icon.chevronUpDown.filled` | `icon_chevron_up_down_filled` | `icon/chevronupdown` · `Style=filled` | `2769:107367` | 채움·선 같은 그림 |
| `Image.ds.icon.chevronUpDown.outlined` | `icon_chevron_up_down_outlined` | `icon/chevronupdown` · `Style=outlined` | `2769:107365` | 채움·선 같은 그림 |
| `Image.ds.icon.chevronWide.down` | `icon_chevron_wide_down` | `icon/chevron-wide` · `Type=down` | `447:7443` |  |
| `Image.ds.icon.chevronWide.left` | `icon_chevron_wide_left` | `icon/chevron-wide` · `Type=right` | `594:11996` | Figma 이름 반대, 그림대로 |
| `Image.ds.icon.chevronWide.right` | `icon_chevron_wide_right` | `icon/chevron-wide` · `Type=left` | `594:11992` | Figma 이름 반대, 그림대로 |
| `Image.ds.icon.chevronWide.up` | `icon_chevron_wide_up` | `icon/chevron-wide` · `Type=up` | `447:7710` |  |
| `Image.ds.icon.close.filled` | `icon_close_filled` | `icon/close` · `Style=filled` | `53:3141` |  |
| `Image.ds.icon.close.outlined` | `icon_close_outlined` | `icon/close` · `Style=outlined` | `53:3143` |  |
| `Image.ds.icon.crop.filled` | `icon_crop_filled` | `icon/crop` · `Style=filled` | `53:4075` |  |
| `Image.ds.icon.crop.outlined` | `icon_crop_outlined` | `icon/crop` · `Style=outlined` | `53:4077` |  |
| `Image.ds.icon.cup.filled` | `icon_cup_filled` | `Icon/cup` · `Property 1=filled` | `2798:98059` |  |
| `Image.ds.icon.cup.outlined` | `icon_cup_outlined` | `Icon/cup` · `Property 1=outlined` | `2798:98057` |  |
| `Image.ds.icon.delete.filled` | `icon_delete_filled` | `icon/delete` · `Style=filled` | `53:3111` |  |
| `Image.ds.icon.delete.outlined` | `icon_delete_outlined` | `icon/delete` · `Style=outlined` | `53:3113` |  |
| `Image.ds.icon.download.filled` | `icon_download_filled` | `icon/download` · `Style=filled` | `53:3325` |  |
| `Image.ds.icon.download.outlined` | `icon_download_outlined` | `icon/download` · `Style=outlined` | `53:3327` |  |
| `Image.ds.icon.envelope.filled` | `icon_envelope_filled` | `icon/envelope` · `Style=filled` | `346:11802` |  |
| `Image.ds.icon.envelope.outlined` | `icon_envelope_outlined` | `icon/envelope` · `Style=outlined` | `346:11803` |  |
| `Image.ds.icon.eyedropper.filled` | `icon_eyedropper_filled` | `icon/eyedropper` · `Style=filled` | `346:11831` |  |
| `Image.ds.icon.eyedropper.outlined` | `icon_eyedropper_outlined` | `icon/eyedropper` · `Style=outlined` | `346:11832` |  |
| `Image.ds.icon.filter.filled` | `icon_filter_filled` | `icon/filter` · `Style=filled` | `53:2964` |  |
| `Image.ds.icon.filter.outlined` | `icon_filter_outlined` | `icon/filter` · `Style=outlined` | `53:2966` |  |
| `Image.ds.icon.flash.filled` | `icon_flash_filled` | `icon/flash` · `Style=filled` | `2706:133924` | 채움·선 같은 그림 |
| `Image.ds.icon.flash.outlined` | `icon_flash_outlined` | `icon/flash` · `Style=outlined` | `2706:133926` | 채움·선 같은 그림 |
| `Image.ds.icon.folder.filled` | `icon_folder_filled` | `icon/folder` · `Style=filled` | `346:11902` | 채움·선 같은 그림 |
| `Image.ds.icon.folder.outlined` | `icon_folder_outlined` | `icon/folder` · `Style=outlined` | `346:11807` | 채움·선 같은 그림 |
| `Image.ds.icon.folderMinus.filled` | `icon_folder_minus_filled` | `icon/folder-minus` · `Style=filled` | `346:11894` |  |
| `Image.ds.icon.folderMinus.outlined` | `icon_folder_minus_outlined` | `icon/folder-minus` · `Style=outlined` | `346:11892` |  |
| `Image.ds.icon.folderPlus.filled` | `icon_folder_plus_filled` | `icon/folder-plus` · `Style=filled` | `346:11882` |  |
| `Image.ds.icon.folderPlus.outlined` | `icon_folder_plus_outlined` | `icon/folder-plus` · `Style=outlined` | `346:11886` |  |
| `Image.ds.icon.folderShared.filled` | `icon_folder_shared_filled` | `icon/folder-shared` · `Style=filled` | `53:3761` | 채움·선 같은 그림 |
| `Image.ds.icon.folderShared.outlined` | `icon_folder_shared_outlined` | `icon/folder-shared` · `Style=outlined` | `53:3763` | 채움·선 같은 그림 |
| `Image.ds.icon.frame.filled` | `icon_frame_filled` | `icon/frame` · `Property 1=hdd-fill` | `2867:160070` | 채움·선 같은 그림 |
| `Image.ds.icon.frame.outlined` | `icon_frame_outlined` | `icon/frame` · `Property 1=hdd` | `2867:160068` | 채움·선 같은 그림 |
| `Image.ds.icon.gender.filled` | `icon_gender_filled` | `icon/gender` · `Style=filled` | `2616:41836` | 채움·선 같은 그림 |
| `Image.ds.icon.gender.outlined` | `icon_gender_outlined` | `icon/gender` · `Style=outlined` | `2616:41835` | 채움·선 같은 그림 |
| `Image.ds.icon.grid.bottomWide.filled` | `icon_grid_bottom_wide_filled` | `icon/grid` · `Layout=bottom-wide, Style=filled` | `53:3925` |  |
| `Image.ds.icon.grid.bottomWide.outlined` | `icon_grid_bottom_wide_outlined` | `icon/grid` · `Layout=bottom-wide, Style=outlined` | `53:3927` |  |
| `Image.ds.icon.grid.mosaic.filled` | `icon_grid_mosaic_filled` | `icon/grid` · `Layout=mosaic, Style=filled` | `53:3920` |  |
| `Image.ds.icon.grid.mosaic.outlined` | `icon_grid_mosaic_outlined` | `icon/grid` · `Layout=mosaic, Style=outlined` | `53:3922` |  |
| `Image.ds.icon.grid.oneByTwo.filled` | `icon_grid_one_by_two_filled` | `icon/grid` · `Layout=grid 1x2, Style=filled` | `53:3910` |  |
| `Image.ds.icon.grid.oneByTwo.outlined` | `icon_grid_one_by_two_outlined` | `icon/grid` · `Layout=grid 1x2, Style=outlined` | `53:3912` |  |
| `Image.ds.icon.grid.split.filled` | `icon_grid_split_filled` | `icon/grid` · `Layout=split, Style=filled` | `53:3930` |  |
| `Image.ds.icon.grid.split.outlined` | `icon_grid_split_outlined` | `icon/grid` · `Layout=split, Style=outlined` | `53:3932` |  |
| `Image.ds.icon.grid.topWide.filled` | `icon_grid_top_wide_filled` | `icon/grid` · `Layout=top-wide, Style=filled` | `53:3935` |  |
| `Image.ds.icon.grid.topWide.outlined` | `icon_grid_top_wide_outlined` | `icon/grid` · `Layout=top-wide, Style=outlined` | `53:3937` |  |
| `Image.ds.icon.grid.twoByTwo.filled` | `icon_grid_two_by_two_filled` | `icon/grid` · `Layout=grid 2x2, Style=filled` | `53:3940` |  |
| `Image.ds.icon.grid.twoByTwo.outlined` | `icon_grid_two_by_two_outlined` | `icon/grid` · `Layout=grid 2x2, Style=outlined` | `53:3942` |  |
| `Image.ds.icon.hashtag.filled` | `icon_hashtag_filled` | `icon/hashtag` · `Style=filled` | `449:7937` | 채움·선 같은 그림 |
| `Image.ds.icon.hashtag.outlined` | `icon_hashtag_outlined` | `icon/hashtag` · `Style=outlined` | `449:7934` | 채움·선 같은 그림 |
| `Image.ds.icon.heart.filled` | `icon_heart_filled` | `icon/heart` · `Style=filled` | `346:11873` |  |
| `Image.ds.icon.heart.outlined` | `icon_heart_outlined` | `icon/heart` · `Style=outlined` | `346:11876` |  |
| `Image.ds.icon.home.filled` | `icon_home_filled` | `icon/home` · `Style=filled` | `53:2842` | 채움·선 같은 그림 |
| `Image.ds.icon.home.outlined` | `icon_home_outlined` | `icon/home` · `Style=outlined` | `53:2847` | 채움·선 같은 그림 |
| `Image.ds.icon.idCard.filled` | `icon_id_card_filled` | `icon/id-card` · `Style=filled` | `2616:41819` | 채움·선 같은 그림, 틀 24×24, 오른쪽 0.5 잘림 |
| `Image.ds.icon.idCard.outlined` | `icon_id_card_outlined` | `icon/id-card` · `Style=outlined` | `2616:41818` | 채움·선 같은 그림, 틀 24×24, 오른쪽 0.5 잘림 |
| `Image.ds.icon.image.filled` | `icon_image_filled` | `icon/image` · `Property 1=fill` | `346:11871` |  |
| `Image.ds.icon.image.outlined` | `icon_image_outlined` | `icon/image` · `Property 1=outlined` | `346:11872` |  |
| `Image.ds.icon.info.filled` | `icon_info_filled` | `icon/info` · `Style=filled` | `53:3029` |  |
| `Image.ds.icon.info.outlined` | `icon_info_outlined` | `icon/info` · `Style=outlined` | `53:3031` |  |
| `Image.ds.icon.layers.filled` | `icon_layers_filled` | `icon/layers` · `Style=filled` | `346:11828` |  |
| `Image.ds.icon.layers.outlined` | `icon_layers_outlined` | `icon/layers` · `Style=outlined` | `346:11881` |  |
| `Image.ds.icon.link.filled` | `icon_link_filled` | `icon/link` · `Style=filled` | `959:39366` | 채움·선 같은 그림 |
| `Image.ds.icon.link.outlined` | `icon_link_outlined` | `icon/link` · `Style=outlined` | `959:39363` | 채움·선 같은 그림 |
| `Image.ds.icon.location.filled` | `icon_location_filled` | `icon/location` · `Style=outlined` | `555:12971` | Figma 이름 반대, 그림대로 |
| `Image.ds.icon.location.outlined` | `icon_location_outlined` | `icon/location` · `Style=filled` | `555:12973` | Figma 이름 반대, 그림대로 |
| `Image.ds.icon.locationArrow.filled` | `icon_location_arrow_filled` | `icon/location-arrow` · `Style=filled` | `2616:41810` | 채움·선 같은 그림 |
| `Image.ds.icon.locationArrow.outlined` | `icon_location_arrow_outlined` | `icon/location-arrow` · `Style=outlined` | `2616:41809` | 채움·선 같은 그림 |
| `Image.ds.icon.megaphone.filled` | `icon_megaphone_filled` | `icon/megaphone` · `Style=filled` | `346:11760` |  |
| `Image.ds.icon.megaphone.outlined` | `icon_megaphone_outlined` | `icon/megaphone` · `Style=outlined` | `346:11761` |  |
| `Image.ds.icon.menu.filled` | `icon_menu_filled` | `icon/menu` · `Style=filled` | `53:2984` |  |
| `Image.ds.icon.menu.outlined` | `icon_menu_outlined` | `icon/menu` · `Style=outlined` | `53:2986` |  |
| `Image.ds.icon.mic.filled` | `icon_mic_filled` | `icon/mic` · `Style=filled` | `346:11862` | 채움·선 같은 그림 |
| `Image.ds.icon.mic.outlined` | `icon_mic_outlined` | `icon/mic` · `Style=outlined` | `346:11839` | 채움·선 같은 그림 |
| `Image.ds.icon.micOff.filled` | `icon_mic_off_filled` | `icon/mic-off` · `Style=filled` | `346:11768` |  |
| `Image.ds.icon.micOff.outlined` | `icon_mic_off_outlined` | `icon/mic-off` · `Style=outlined` | `346:11860` |  |
| `Image.ds.icon.moreHorizontal.filled` | `icon_more_horizontal_filled` | `icon/more-horizontal` · `Style=filled` | `53:2974` |  |
| `Image.ds.icon.moreHorizontal.outlined` | `icon_more_horizontal_outlined` | `icon/more-horizontal` · `Style=outlined` | `53:2976` |  |
| `Image.ds.icon.moreVertical.filled` | `icon_more_vertical_filled` | `icon/more-vertical` · `Style=filled` | `53:3430` |  |
| `Image.ds.icon.moreVertical.outlined` | `icon_more_vertical_outlined` | `icon/more-vertical` · `Style=outlined` | `53:3432` |  |
| `Image.ds.icon.music.filled` | `icon_music_filled` | `icon/music` · `Property 1=hdd-fill` | `2867:160075` | 채움·선 같은 그림 |
| `Image.ds.icon.music.outlined` | `icon_music_outlined` | `icon/music` · `Property 1=hdd` | `2867:160073` | 채움·선 같은 그림 |
| `Image.ds.icon.note.filled` | `icon_note_filled` | `icon/note` · `Style=filled` | `346:11762` |  |
| `Image.ds.icon.note.outlined` | `icon_note_outlined` | `icon/note` · `Style=outlined` | `346:11851` |  |
| `Image.ds.icon.overlay.filled` | `icon_overlay_filled` | `icon/overlay` · `Property 1=hdd-fill` | `346:11784` | 채움·선 같은 그림 |
| `Image.ds.icon.overlay.outlined` | `icon_overlay_outlined` | `icon/overlay` · `Property 1=hdd` | `346:11880` | 채움·선 같은 그림 |
| `Image.ds.icon.paint.filled` | `icon_paint_filled` | `icon/paint` · `Property 1=hdd-fill` | `2891:163020` | 채움·선 같은 그림 |
| `Image.ds.icon.paint.outlined` | `icon_paint_outlined` | `icon/paint` · `Property 1=hdd` | `2891:163018` | 채움·선 같은 그림 |
| `Image.ds.icon.people.filled` | `icon_people_filled` | `icon/people` · `Style=filled` | `2616:41840` |  |
| `Image.ds.icon.people.outlined` | `icon_people_outlined` | `icon/people` · `Style=outlined` | `2616:41839` |  |
| `Image.ds.icon.person.filled` | `icon_person_filled` | `icon/person` · `Style=filled` | `53:2859` |  |
| `Image.ds.icon.person.outlined` | `icon_person_outlined` | `icon/person` · `Style=outlined` | `53:2861` |  |
| `Image.ds.icon.pin.filled` | `icon_pin_filled` | `icon/pin` · `Style=filled` | `53:3079` |  |
| `Image.ds.icon.pin.outlined` | `icon_pin_outlined` | `icon/pin` · `Style=outlined` | `53:3081` |  |
| `Image.ds.icon.playBox.filled` | `icon_play_box_filled` | `icon/play-box` · `Style=filled` | `2616:41788` | 채움·선 같은 그림 |
| `Image.ds.icon.playBox.outlined` | `icon_play_box_outlined` | `icon/play-box` · `Style=outlined` | `2616:41783` | 채움·선 같은 그림 |
| `Image.ds.icon.playCircle.filled` | `icon_play_circle_filled` | `icon/play` · `Property 1=hdd-fill` | `2867:161199` | 채움·선 같은 그림 |
| `Image.ds.icon.playCircle.outlined` | `icon_play_circle_outlined` | `icon/play` · `Property 1=hdd` | `2867:161197` | 채움·선 같은 그림 |
| `Image.ds.icon.playStack.filled` | `icon_play_stack_filled` | `icon/play` · `Style=filled` | `53:4110` |  |
| `Image.ds.icon.playStack.outlined` | `icon_play_stack_outlined` | `icon/play` · `Style=outlined` | `53:4114` |  |
| `Image.ds.icon.plus.filled` | `icon_plus_filled` | `icon/plus` · `Style=filled` | `53:2924` |  |
| `Image.ds.icon.plus.outlined` | `icon_plus_outlined` | `icon/plus` · `Style=outlined` | `53:2926` |  |
| `Image.ds.icon.poll.filled` | `icon_poll_filled` | `icon/poll` · `Style=filled` | `809:18297` |  |
| `Image.ds.icon.poll.outlined` | `icon_poll_outlined` | `icon/poll` · `Style=outlined` | `809:18295` |  |
| `Image.ds.icon.popcorn.filled` | `icon_popcorn_filled` | `icon/popcorn` · `Property 1=filled` | `2798:98148` | 채움·선 같은 그림 |
| `Image.ds.icon.popcorn.outlined` | `icon_popcorn_outlined` | `icon/popcorn` · `Property 1=outlined` | `2798:98146` | 채움·선 같은 그림 |
| `Image.ds.icon.question.filled` | `icon_question_filled` | `icon/question` · `Style=filled` | `53:3766` |  |
| `Image.ds.icon.question.outlined` | `icon_question_outlined` | `icon/question` · `Style=outlined` | `53:3768` |  |
| `Image.ds.icon.questionAlt.filled` | `icon_question_alt_filled` | `icon/question-alt` · `Style=filled` | `2238:129491` |  |
| `Image.ds.icon.questionAlt.outlined` | `icon_question_alt_outlined` | `icon/question-alt` · `Style=outlined` | `2238:129488` |  |
| `Image.ds.icon.refresh.filled` | `icon_refresh_filled` | `icon/refresh` · `Style=filled` | `278:2219` | 채움·선 같은 그림, 그림자 제거, 틀 24×24 |
| `Image.ds.icon.refresh.outlined` | `icon_refresh_outlined` | `icon/refresh` · `Style=outlined` | `278:2225` | 채움·선 같은 그림, 그림자 제거, 틀 24×24 |
| `Image.ds.icon.scale.filled` | `icon_scale_filled` | `icon/scale` · `Style=filled` | `2706:133890` | 채움·선 같은 그림 |
| `Image.ds.icon.scale.outlined` | `icon_scale_outlined` | `icon/scale` · `Style=outlined` | `2706:133892` | 채움·선 같은 그림 |
| `Image.ds.icon.search.filled` | `icon_search_filled` | `icon/search` · `Style=filled` | `53:2854` |  |
| `Image.ds.icon.search.outlined` | `icon_search_outlined` | `icon/search` · `Style=outlined` | `2341:18059` |  |
| `Image.ds.icon.send.filled` | `icon_send_filled` | `icon/send` · `Style=filled` | `53:3330` |  |
| `Image.ds.icon.send.outlined` | `icon_send_outlined` | `icon/send` · `Style=outlined` | `53:3332` |  |
| `Image.ds.icon.setting.filled` | `icon_setting_filled` | `icon/setting` · `Style=filled` | `53:3049` |  |
| `Image.ds.icon.setting.outlined` | `icon_setting_outlined` | `icon/setting` · `Style=outlined` | `53:3051` |  |
| `Image.ds.icon.telegram.filled` | `icon_telegram_filled` | `icon/telegram` · `Style=filled` | `346:11766` |  |
| `Image.ds.icon.telegram.outlined` | `icon_telegram_outlined` | `icon/telegram` · `Style=outlined` | `346:11767` |  |
| `Image.ds.icon.text.filled` | `icon_text_filled` | `icon/text` · `Style=filled` | `2716:57317` | 채움·선 같은 그림 |
| `Image.ds.icon.text.outlined` | `icon_text_outlined` | `icon/text` · `Style=outlined` | `2716:57319` | 채움·선 같은 그림 |
| `Image.ds.icon.timer.filled` | `icon_timer_filled` | `icon/timer` · `Style=filled` | `2706:133909` | 채움·선 같은 그림 |
| `Image.ds.icon.timer.outlined` | `icon_timer_outlined` | `icon/timer` · `Style=outlined` | `2706:133913` | 채움·선 같은 그림 |
| `Image.ds.icon.trash.filled` | `icon_trash_filled` | `icon/trash` · `Style=filled` | `53:3172` | 채움·선 같은 그림 |
| `Image.ds.icon.trash.outlined` | `icon_trash_outlined` | `icon/trash` · `Style=outlined` | `53:3174` | 채움·선 같은 그림 |
| `Image.ds.icon.video.filled` | `icon_video_filled` | `icon/video` · `Style=filled` | `346:11822` |  |
| `Image.ds.icon.video.outlined` | `icon_video_outlined` | `icon/video` · `Style=outlined` | `346:11825` |  |
| `Image.ds.icon.volume.filled` | `icon_volume_filled` | `icon/volume` · `Style=filled` | `346:11865` |  |
| `Image.ds.icon.volume.outlined` | `icon_volume_outlined` | `icon/volume` · `Style=outlined` | `346:11868` |  |
| `Image.ds.icon.volumeOff.filled` | `icon_volume_off_filled` | `icon/volume-off` · `Style=filled` | `346:11863` |  |
| `Image.ds.icon.volumeOff.outlined` | `icon_volume_off_outlined` | `icon/volume-off` · `Style=outlined` | `346:11899` |  |
| `Image.ds.icon.xCircle.filled` | `icon_x_circle_filled` | `icon/x_circle` · `Property 1=filled` | `2836:148101` | 채움·선 같은 그림 |
| `Image.ds.icon.xCircle.outlined` | `icon_x_circle_outlined` | `icon/x_circle` · `Property 1=outlined` | `2836:148099` | 채움·선 같은 그림 |
| `Image.ds.icon.zoomIn.filled` | `icon_zoom_in_filled` | `icon/zoom-in` · `Style=filled` | `346:11789` |  |
| `Image.ds.icon.zoomIn.outlined` | `icon_zoom_in_outlined` | `icon/zoom-in` · `Style=outlined` | `346:11791` |  |
| `Image.ds.icon.zoomOut.filled` | `icon_zoom_out_filled` | `icon/zoom-out` · `Style=filled` | `346:11809` |  |
| `Image.ds.icon.zoomOut.outlined` | `icon_zoom_out_outlined` | `icon/zoom-out` · `Style=outlined` | `346:11787` |  |

## 주요 진입점
- `Sources/Access/Color+DesignSystem.swift` · `CGFloat+DesignSystem.swift`
- `Sources/Tokens/Typography/TextStyle.swift` · `Typography.swift`
- `Sources/Tokens/Primitive/PrimitiveColor.swift` · `AlphaColor.swift`
- `Sources/Tokens/Semantic/SemanticColor.swift` · `SocialColor.swift`
- `Sources/Foundation/TokenColor.swift` · `ThemedColor.swift`
- `Sources/Components/` · 헤더·탭바·하단 버튼 영역은 `Sources/Components/Frame/`

## 테스트 포인트
- 원시 색 34 · 알파 색 20 · 의미 색 63 쌍 · 숫자 · 글자 스타일 21 값이 Figma 표와 같다
- 의미 색의 공개 `Color` 가 다크·라이트·정해지지 않은 trait 에서 맞는 값을 낸다
- 호스트 앱 없는 테스트에서 `TextStyle` 글자가 Pretendard 로 그려진다
- 버튼: `.controlSize` 크기 대응(기본 sm·md·lg, 액션 s·m), 계열·상태(기본·눌림·비활성)별 색과 불투명도, 소셜 버튼 문구·색·치수
- 입력 칸·체크박스·칩·검색 칸·상태 드롭다운의 상태별 색과 치수
- 글자 수 규칙(빈 값, 정확히 최대, 최대+1, 이모지 묶음, 조합 중, 붙여넣기, 긴 값에서 지우기·더하기)과 UIKit 칸의 조합 뒤 자르기
- UIKit 칸과 포커스의 양방향 연결
- 탭 아이콘의 모양(선택·「+」)·색·크기 28, 툴바 제목·아이콘 값, 헤더 배경, 뒤로 가기 그림 24, 하단 버튼 영역의 배치별 너비·여백·높이

## 명령
```bash
xcodebuild -workspace Mozi.xcworkspace -scheme SharedDesignSystem -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.4.1' -skipMacroValidation test
```

## 관련 문서
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../../docs/CONVENTIONS.md)
