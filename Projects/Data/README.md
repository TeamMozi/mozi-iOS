# Data

## 책임
- DTO, Datasource, `*RepositoryImpl`, `*ClientFactory`

## 현재 상태
- placeholder 골격

## 이후 패턴
- `Data/<Name>/{DTO,Datasource,Repository}`
- `*RepositoryImpl`
- `*ClientFactory`

## 의존
- 허용: Domain, Core/*, SharedLogger, SharedUtils
- 금지: Feature

## 내부 규칙
- Domain `*Client` 의 live 구현을 factory 로 제공
- App 조립 지점에서 factory 등록
- Feature 가 Data 를 직접 import 하지 않음

## 주요 진입점
- (현재) `Sources/Placeholder.swift`
- (이후) `*ClientFactory`

## 테스트 포인트
- repository/factory 매핑 (구현 시)

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
