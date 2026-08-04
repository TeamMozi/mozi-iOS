# Feature

## 책임
- 앱 화면 상태와 네비게이션 골격
- Root / AppCoordinator / Scene 구성

## 현재 상태
- Root + AppCoordinator + Placeholder scene
- 딥링크: `mozi://home`

## 의존
- 허용: Domain, SharedUtils, SharedDesignSystem, SharedLogger, ThirdParty, ThirdPartyUI
- 금지: Data, Core*, ThirdPartyCore

## 내부 규칙
- Feature 모듈 분리 금지, 기능 분리는 폴더
- Scene 내부 flat (`*Feature`, `*View`)
- Scene 간 직접 참조 금지
- 외부 요청은 delegate bubble-up
- Feature 는 Domain `*Client` 만 사용
- 전역 전환/딥링크/overlay 는 AppCoordinator

## 주요 진입점
- `RootFeature`, `RootView`
- `AppCoordinatorFeature`, `AppCoordinatorView`
- `Scene/Placeholder`

## 테스트 포인트
- 부트스트랩 후 main placeholder 진입
- 딥링크 파싱 (`mozi://home`, https home, unknown)

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
