# Domain

## 책임
- Entity, Error, Domain port (`*Client`)

## 현재 상태
- Auth 포트 추가 (`AuthSession`, `AuthError`, `AuthProvider`, `AuthClient`)
- User 포트 추가 (`UserProfile`, `OnboardingDraft`, `Gender`, `UserLimit`, `UserError`, `UserClient`). `UserClient.completeOnboarding` 은 값을 돌려주지 않고, 성공하면 기기 세션의 프로필 완료 값을 참으로 바꾼다
- Interest(카테고리) 포트 추가 (`Interest`, `InterestError`, `InterestClient`). 식별자는 문자열이고 정수 변환은 Data 가 맡는다. 모임도 `Meeting.category` 로 같은 `Interest` 를 쓴다. `Category` 는 Objective-C 런타임 타입과 부딪혀 쓰지 않는다
- Meeting 포트 추가 (`Meeting`, `MeetingDraft`, `EncoreDraft`, `EncoreResult`, `MeetingMember`, `MeetingLimit` 외 값 타입, `MeetingError`, `MeetingClient`)
- Series 포트 추가 (`Series`, `SeriesEpisode`, `HostedSeries`, `SeriesDraft`, `SeriesUpdateDraft`, `SeriesLimit`, `SeriesError`, `SeriesClient`)
- Place 포트 추가 (`Place`, `Region`, `RegionGroup`, `PlaceError`, `PlaceClient`)
- Meeting·Series·Place·Interest Client 는 `previewValue` 에 가짜 데이터(`*PreviewData`)를 둔다. `InterestClient.previewValue` 는 시안 12개 이름(`InterestClient.previewInterests`)이고 가짜 모임 카테고리도 이 목록을 쓴다. `UserClient.previewValue` 는 1초 뒤 성공이다. `testValue` 는 비워 둔다
- 페이지 동작 셋: `SeriesClient.episodes`(시리즈 회차, 최신 회차부터), `MeetingClient.hostedMeetings`(이전 모임 불러오기 최신순), `SeriesClient.hostedSeries`(시리즈별, 최근 모임 최대 `HostedSeries.recentMeetingLimit` 개). 불러오기 둘은 서버 API 가 없다
- 첫 요청 상수: `MeetingClient.hostedMeetingsFirstPage`(최신순 10개), `SeriesClient.moreEpisodesFirstPage`(시리즈별 더보기 5개). 그 밖의 목록은 `PageRequest.first`. 화면은 이 상수와 받은 `next` 만 보낸다

## 이후 패턴
- `Domain/<Name>/{Model,Client,Error}`
- 여러 기능이 같이 쓰는 모델은 `Domain/Common/Model` (`Page`, `PageRequest`, `ImageInput`)
- `Model` 안은 개념 폴더로 나누고 파일을 바로 두지 않는다 (예: `Meeting/Model/{Meeting,Host,Member,Draft,Encore}`)

## 의존
- 허용: SharedUtils, ThirdParty
- 금지: Data, Core*, Feature

## 내부 규칙
- 포트 이름은 `*Client`
- Domain Client 는 `@DependencyClient` 매크로 사용
- Feature 가 의존하는 유일한 도메인 경계
- UseCase 층 없음

## 주요 진입점
- `Sources/Auth/Client/AuthClient.swift`
- `Sources/Auth/Model/AuthSession.swift`
- `Sources/Auth/Model/AuthProvider.swift`
- `Sources/Auth/Error/AuthError.swift`
- `Sources/User/Client/UserClient.swift`
- `Sources/User/Model/UserProfile.swift`
- `Sources/User/Model/OnboardingDraft.swift`
- `Sources/User/Model/Gender.swift`
- `Sources/Interest/Model/Interest/Interest.swift`
- `Sources/User/Error/UserError.swift`
- `Sources/Meeting/Client/MeetingClient.swift`
- `Sources/Meeting/Client/MeetingPreviewData.swift`
- `Sources/Meeting/Model/Meeting/Meeting.swift`
- `Sources/Meeting/Model/Draft/MeetingDraft.swift`
- `Sources/Meeting/Model/Encore/EncoreResult.swift`
- `Sources/Meeting/Model/Draft/MeetingLimit.swift`
- `Sources/Meeting/Error/MeetingError.swift`
- `Sources/Series/Client/SeriesClient.swift`
- `Sources/Series/Client/SeriesPreviewData.swift`
- `Sources/Series/Model/Series/Series.swift`
- `Sources/Series/Model/Hosted/HostedSeries.swift`
- `Sources/Series/Model/Draft/SeriesLimit.swift`
- `Sources/Series/Error/SeriesError.swift`
- `Sources/Place/Client/PlaceClient.swift`
- `Sources/Place/Client/PlacePreviewData.swift`
- `Sources/Place/Model/Place/Place.swift`
- `Sources/Place/Error/PlaceError.swift`
- `Sources/User/Model/UserLimit.swift`
- `Sources/Interest/Client/InterestClient.swift`
- `Sources/Interest/Client/InterestPreviewData.swift`
- `Sources/Interest/Error/InterestError.swift`

## 테스트 포인트
- 세션 동등성/Codable 왕복
- `AuthClient.testValue` 생성 가능성
- User model 동등성/Codable 왕복
- `UserClient.testValue` 생성 가능성
- `InterestClient.previewValue` 의 12개 이름과 순서, `InterestError` 세 종류
- `UserError` 일곱 종류, `Gender` 둘, `UserLimit` 상한(10·50·5), `UserClient.previewValue` 성공
- Meeting·Series·Place model·에러 동등성, 입력 초안 가입 방식 처음 값 `instant`
- `MeetingLimit`·`SeriesLimit` 상한 값
- `MeetingClient`·`SeriesClient`·`PlaceClient` 의 `testValue`·`previewValue` 생성 가능성
- `previewValue` 가짜 데이터가 상한을 넘지 않음, 모임 넷이 나의 참여 상태 넷을 모두 담음
- 첫 요청 상수 값(`hostedMeetingsFirstPage` 10개, `moreEpisodesFirstPage` 5개), `HostedSeries.recentMeetingLimit` 3
- `previewValue` 페이지 동작: 첫 페이지 개수와 `next`, 마지막 페이지 `next == nil`, 범위 밖·음수 페이지·`size` 0 이하는 빈 목록과 `nil`, 시리즈별 최근 모임이 회차 목록의 앞 3개

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
