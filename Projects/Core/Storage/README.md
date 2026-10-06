# CoreStorage

## 책임
- 키체인·UserDefaults 에 `Codable` 값 저장/읽기/삭제

## 의존
- 허용: SharedUtils, ThirdPartyCore
- 금지: Domain, Data, Feature, App

## 내부 규칙
- 밖에서는 `StorageConfiguration` 과 `StorageFactory` 로만 만든다. `DefaultKeychainStorage`·`DefaultUserDefaultsStorage` 는 `internal`
- factory 하나에 함수 둘이다. 필요한 저장소만 만든다
- 키체인 service 는 `StorageConfiguration.keychainService` 로만 정한다. 기본값이 없다. App 이 Bundle ID 를 넣는다
- `userDefaultsSuiteName` 이 nil 이면 `UserDefaults.standard`
- 키체인 항목 접근성은 `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`

## 주요 진입점
- `StorageConfiguration`
- `StorageFactory.makeKeychain(config:)` / `makeUserDefaults(config:)`
- `KeychainStorage` / `KeychainError`
- `UserDefaultsStorage` / `UserDefaultsError`

## 테스트 포인트
- `makeKeychain` 이 `keychainService` 를 저장소에 넘기는지. 실제 키체인은 쓰지 않는다. 호스트 앱 없는 테스트 번들은 `-34018` 로 실패한다
- `makeUserDefaults` 가 suite 이름을 쓰고, 없으면 standard 를 쓰는지

## 관련 문서
- [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../../docs/CONVENTIONS.md)
