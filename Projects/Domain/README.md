# Domain

## 책임
- Entity, Error, Domain port (`*Client`)

## 현재 상태
- placeholder 골격

## 이후 패턴
- `Domain/<Name>/{Model,Client,Error}`

## 의존
- 허용: SharedUtils, ThirdParty
- 금지: Data, Core*, Feature

## 내부 규칙
- 포트 이름은 `*Client`
- Feature 가 의존하는 유일한 도메인 경계
- UseCase 층 없음

## 주요 진입점
- (현재) `Sources/Placeholder.swift`
- (이후) `*Client` 정의

## 테스트 포인트
- 순수 모델/ 에러 동작 (구현 시)

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
