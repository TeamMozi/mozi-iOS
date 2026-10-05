# SharedDesignSystem

## 책임
- Figma 파일 `hnGl2AWCk8XCvrNK7MBkvq` 의 색·숫자·글자 스타일을 코드 토큰으로 연다
- 공통 부품: `DesignButton`, `SocialLoginButton`, `DesignText`, `ScreenStatus` · `.screenStatus`
- 글꼴(Pretendard 네 굵기)과 에셋(로고·소셜 아이콘·로그인 숏폼 사진)

## 의존
- 허용: SharedUtils
- Feature·DemoApp 은 `Color.ds` · `CGFloat.ds` · `TextStyle.ds` 와 공통 부품만 쓴다

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
- `Color.ds.social.*` 다섯만 있다. 카카오·애플 브랜드 지침 색이라 모드와 상관없다
  - `kakao` #FEE500 · `kakaoContent` #000000 · `appleBackground` #FFFFFF · `appleBorder` #000000 · `appleContent` #000000
- 이전의 Secondary 색 9개, System orange, `CGFloat.ds.dim`, `Font.ds` 는 지웠다

## Figma 와 맞춰 볼 것
- `overlay/gray/40`·`overlay/gray/80` 은 다른 gray(#AFAFAF)와 RGB 가 다르다(#706D82·#423F55). Figma 값 그대로다
- 의미 색 가운데 system·swatch 원시 색을 가리키는 것이 없다. 오류·성공 색이 필요하면 Figma 에 의미 색이 먼저 있어야 한다

## 부품
- `DesignButtonVariant` 넷은 Figma 버튼 묶음 색을 쓴다: primary → main, secondary → neutral, outlined → ghost(테두리는 글자 색), text → text(바탕 투명)
- 버튼 높이: sm 36 · md 40 · lg 48 (`buttonHeight.controlSm·controlMd·controlLg`)
- 글자는 `DesignText(_:style:)` 로 쓴다. `style.font` 만 꺼내면 줄 높이·자간이 빠진다

## 글꼴
- `TextStyle.font` 가 처음 불릴 때 Tuist 생성 `SharedDesignSystemFontFamily.registerAllCustomFonts()` 를 한 번 부른다
- 앱·미리보기·테스트는 글꼴을 따로 등록하지 않는다

## 주요 진입점
- `Sources/Access/Color+DesignSystem.swift` · `CGFloat+DesignSystem.swift`
- `Sources/Tokens/Typography/TextStyle.swift` · `Typography.swift`
- `Sources/Tokens/Primitive/PrimitiveColor.swift` · `AlphaColor.swift`
- `Sources/Tokens/Semantic/SemanticColor.swift` · `SocialColor.swift`
- `Sources/Foundation/TokenColor.swift` · `ThemedColor.swift`
- `Sources/Components/`

## 테스트 포인트
- 원시 색 34 · 알파 색 20 · 의미 색 63 쌍 · 숫자 · 글자 스타일 21 값이 Figma 표와 같다
- 의미 색의 공개 `Color` 가 다크·라이트·정해지지 않은 trait 에서 맞는 값을 낸다
- 호스트 앱 없는 테스트에서 `TextStyle` 글자가 Pretendard 로 그려진다
- 버튼 모양별 색, 소셜 버튼 색

## 명령
```bash
xcodebuild -workspace Mozi.xcworkspace -scheme SharedDesignSystem -destination 'platform=iOS Simulator,name=iPhone 14,OS=18.6' -skipMacroValidation test
```

## 관련 문서
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../../docs/CONVENTIONS.md)
