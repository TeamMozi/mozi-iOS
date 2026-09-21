# Feature

## 책임
- 앱 화면 상태와 네비게이션 골격
- Root / Flow / Scene 구성

## 현재 상태
- Root + RootFlow + Flow 컨테이너 일곱 (Onboarding, MainTab, 탭 다섯)
- 탭 다섯: `shortform` / `search` / `chat` / `myPage` / `create`
- Scene: Login / OnboardingPlaceholder / MyPagePlaceholder / Placeholder
- 탭 넷은 Placeholder 를 나눠 쓰고 표시 글자를 밖에서 받는다. 마이 탭만 전용 화면을 쓴다
- 탭 컨테이너의 `Route` 는 케이스가 0개다. 쌓일 화면이 생기면 케이스를 더한다
- restore 기반 로그인 게이트
- 딥링크: `mozi://home` (main 진입 후 처리, 라우팅은 미구현)

## 의존
- 허용: Domain, SharedUtils, SharedDesignSystem, SharedLogger, ThirdParty, ThirdPartyUI
- 금지: Data, Core*, ThirdPartyCore

## 내부 규칙
- Feature 모듈 분리 금지, 기능 분리는 폴더
- Scene 내부 flat (`*Feature`, `*View`)
- Scene 간 직접 참조 금지
- 외부 요청은 delegate bubble-up
- Feature 는 Domain `*Client` 만 사용
- 전역 전환/딥링크/overlay 는 RootFlowFeature
- 탭 사이 이동은 MainTabFeature 만 한다. Scene 이 `selectedTab` 을 직접 바꾸지 않는다
- 컨테이너는 화면을 그리지 않는다. 경로와 자식만 갖는다

## 주요 진입점
- `RootFeature`, `RootView`
- `RootFlowFeature`, `RootFlowView`
- `Flow/MainTab` — 탭 열거형, 탭 선택, `TabView`
- `Flow/Onboarding`, `Flow/Shortform`, `Flow/Search`, `Flow/Chat`, `Flow/MyPage`, `Flow/Create`
- `Scene/Login`
- `Scene/OnboardingPlaceholder`
- `Scene/MyPagePlaceholder` — 임시 로그아웃이 여기 하나뿐이다
- `Scene/Placeholder`

## 테스트 포인트
- restore 분기: nil → login / profileCompleted false → onboarding / true → main
- LoginFeature 성공/실패/취소/중복 탭 방지
- 로그아웃 복귀 네 칸: MyPagePlaceholder → MyPageFlow → MainTab → RootFlow → login
- MainTab 탭 선택과 기본 탭(`shortform`)
- 딥링크 파싱 (`mozi://home`, https home, unknown)

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
