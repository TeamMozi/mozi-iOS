# Feature

## 책임
- 앱 화면 상태와 네비게이션 골격
- Root / Flow / Scene 구성

## 현재 상태
- Root + RootFlow + Flow 컨테이너 여덟 (Onboarding, MainTab, 탭 넷, MeetingDetail, CreateMeeting)
- 탭 다섯: `shortform` / `search` / `chat` / `myPage` / `create`. 「만들기」(`create`) 탭은 Flow 가 없다. 누르면 MainTab 이 고른 탭을 바꾸지 않고 모임 만들기 시트(`createMeeting`)를 띄우고, 닫으면 보던 탭에 남는다
- Scene: Login / ProfileSetting / InterestSetting / MyPagePlaceholder / Placeholder / NavigationSample / MeetingForm / PlaceSearch / Poster / PreviousMeeting / SeriesInfo
- 탭 셋은 Placeholder 를 나눠 쓰고 표시 글자를 밖에서 받는다. 마이 탭만 전용 화면을 쓴다
- Flow 여섯(Onboarding, 탭 넷, CreateMeeting)은 `@Reducer enum Route` 와 `StackState<Route.State>` 로 화면을 쌓는다. 숏폼 `Route` 에 견본 화면(`sample`), 온보딩 `Route` 에 카테고리 설정(`interestSetting`) 한 칸씩, 모임 만들기 `Route` 에 네 칸이 있고 나머지 셋은 비어 있다
- restore 기반 로그인 게이트
- 딥링크: `mozi://home`. 메인에서 받으면 MainTab `openDeepLink` 가 숏폼 탭을 고르고 숏폼의 쌓인 화면을 비운다. 로그인·온보딩 중에는 보관했다가 메인에 들어갈 때 처리한다
- 온보딩: 프로필 설정(root) → 카테고리 설정. 프로필 「시작하기」는 서버에 보내지 않고 입력값(`OnboardingDraft`)을 delegate 로 올리고, Flow 가 카테고리 설정을 쌓는다. 카테고리 「완료」가 `UserClient.completeOnboarding` 을 한 번 불러 프로필·사진·카테고리를 저장하고 `delegate(.finished)` 로 RootFlow 가 메인으로 넘긴다. 프로필 뒤로는 Flow 가 `authClient.logout()` 을 불러 로그인으로 보낸다. 고른 카테고리는 Flow 가 들고 있어 다시 들어와도 남는다
- 모임 만들기(시트 안 `CreateMeetingFlowFeature`): 모임 만들기 입력(root) → (이전 모임 불러오기 / 장소 선택) → 포스터 → (앵콜이면 시리즈 정보) → 만들기. 불러오기·장소는 고르면 입력에 넣고 그 화면을 닫는다. 포스터에서 고른 것은 Flow 가 들고 있다. 시리즈에 안 묶인 지난 모임을 불러왔으면 앵콜(2회차)이라 포스터 다음에 시리즈 정보를 쌓고 `MeetingClient.createEncore` 를, 아니면 `create` 를 부른다. 요청 중 표시와 실패 창은 요청을 보낸 화면 상태에 넣고 시트에 남는다. 만들면 `delegate(.created)` 로 MainTab 이 시트를 닫는다. 앵콜에서 시리즈만 실패하면(`createdWithoutSeries`) 다시 눌러 모임이 하나 더 생기지 않게 시트를 닫고 MainTab 이 안내를 한 번 띄운다. X 는 확인 없이 입력을 버리고 닫는다. 만든 모임 상세로 잇기는 아직 없다

## 의존
- 허용: Domain, SharedUtils, SharedDesignSystem, SharedLogger, ThirdParty, ThirdPartyUI
- 금지: Data, Core*, ThirdPartyCore

## 내부 규칙
- Feature 모듈 분리 금지, 기능 분리는 폴더
  - 다시 볼 조건: Feature 스킴 증분 빌드가 20초를 넘으면 화면별 분리를 다시 검토한다 (2026-09-25 결정. 당시 31파일, 6초)
- Scene 내부 flat (`*Feature`, `*View`)
- Scene 간 직접 참조 금지
- 외부 요청은 delegate bubble-up
- Feature 는 Domain `*Client` 만 사용
- 전역 전환/딥링크는 RootFlowFeature. 화면의 불러오는 중·오류는 그 화면 State 의 `screen` 이 들고 `.screenStatus` 로 띄운다
- 탭 사이 이동은 MainTabFeature 만 한다. Scene 이 `selectedTab` 을 직접 바꾸지 않는다
- 컨테이너는 화면을 그리지 않는다. 경로와 자식만 갖는다
- Flow 는 `@Reducer enum Route` · `var path = StackState<Route.State>()` · `case path(StackActionOf<Route>)` · `.forEach(\.path, action: \.path)` 로 화면을 쌓는다. View 는 `NavigationStack(path: $store.scope(state: \.path, action: \.path))` 로 그린다
- 화면은 다음 화면을 직접 열지 않는다. delegate 로 올리고 Flow 가 `path` 에 더한다. 화면을 더할 때는 자기 탭 `Route` 에 case 하나와 delegate 처리만 더한다
- `Route.State`·`Route.Action` 은 Flow 파일 아래 `extension <Flow>.Route.State: Equatable {}` 와 `extension <Flow>.Route.Action: Equatable {}` 로 Equatable 을 맞춘다. 케이스가 없는 `Route` 의 목적지는 `{ _ in EmptyView() }` 로 둔다 (빈 `switch` 는 컴파일되지 않는다)
- 화면이나 상태를 더하는 작업은 데모 앱 목록에도 한 줄 더한다. 방법은 [DemoApp README](../DemoApp/README.md)
- 컨테이너와 화면 리듀서는 body 끝에 `.logged(as: Self.self, children: [...])` 를 붙이고, 자식 Scope·ifLet 의 액션 이름을 `children` 에 넘긴다. 자식이 없으면 `children: []`. 붙인 곳은 `Tests/Log/FeatureLogAttachmentTests` 표에도 더한다
- 오류 문구는 `Common/Error/FeatureErrorMessage` 한 벌을 쓴다. Domain 오류 타입마다 함수 하나가 종류마다 문구 하나를 준다. 동작 이름이 필요한 화면만 몇 종류를 덮어쓴다(로그인의 `unauthorized`·`storage`, 로그아웃의 `logoutFailure(for:)`, 모임 화면·모임 만들기의 `meetingFailure(for:action:conflict:)`, 스냅 포인트 목록 읽기의 `snapPointFailure(for:action:)` 와 동작 문구 `MeetingAction`, 장소 검색의 `forbidden`·`notFound`·`conflict`·`unknown`, 이전 모임의 `validation`·`forbidden`·`notFound`·`conflict`·`joinRestricted`(모임 오류만)·`unknown`). 서버 message 는 화면에 띄우지 않고 로그에만 남는다. 문구가 없는 종류(`AuthError.cancelled`)는 알림 창을 띄우지 않는다. 새 Domain 오류 타입은 이 표에 함수 하나를 더한다

## 주요 진입점
- `RootFeature`, `RootView`
- `RootFlowFeature`, `RootFlowView`
- `Flow/MainTab` — 탭 열거형, 탭 선택, `TabView`. 탭바 아이콘은 디자인 시스템 `TabBarIcon`(`MainTabFeature.Tab.tabBarIcon`)
- `Flow/Onboarding`, `Flow/Shortform`, `Flow/Search`, `Flow/Chat`, `Flow/MyPage`
- `Flow/CreateMeeting` — 모임 만들기 시트 안 화면 쌓기와 만들기 요청
- `Scene/Login`
- `Scene/ProfileSetting` — 온보딩 프로필 입력. 뒤로는 로그아웃(Flow 가 부름)
- `Scene/InterestSetting` — 카테고리 1~5개 고르기와 「완료」 저장. 칸 그림은 `InterestIcon` 이 서버 이름으로 짝짓고, 시안에 없는 이름은 「기타」 그림
- `Scene/MeetingForm` — 모임 만들기 입력. 필수 다섯 칸(카테고리·이름·날짜와 시간·장소·최대 인원)이 차야 → 가 켜진다
- `Scene/PreviousMeeting` — 이전 모임 불러오기. 최신순(`MeetingClient.hostedMeetings`)·시리즈별(`SeriesClient.hostedSeries`)
- `Scene/PlaceSearch` — 장소 선택. 키보드 검색 키로 `PlaceClient.search` 를 부른다. 지도 자리는 비워 둔다
- `Scene/Poster` — 포스터 사진 한 장(「기본」 견본 · 「내 사진」 보관함 `PosterPhotoLibrary` · 불러온 지난 포스터)과 배경음악(`MeetingClient.popularBackgroundMusics`). 지난 포스터는 `ImageInput.reuse(URL)` 로 이어 쓴다
- `Scene/SeriesInfo` — 앵콜일 때 시리즈명·소개
- `Scene/MyPagePlaceholder` — 임시 로그아웃이 여기 하나뿐이다
- `Scene/Placeholder`
- `Scene/NavigationSample` — 숏폼 탭 견본(제목과 「다음」). 본 앱에서는 쌓지 않는다. 세로 피드 화면이 숏폼을 채울 때 데모 「탭 안 이동」과 함께 지운다

## 테스트 포인트
- restore 분기: nil → login / profileCompleted false → onboarding / true → main
- LoginFeature 성공/실패/취소/중복 탭 방지
- 로그아웃 복귀: MyPagePlaceholder → MyPageFlow → MainTab → RootFlow → login, 온보딩 프로필 뒤로 → OnboardingFlow → RootFlow → login(보관한 딥링크 남음)
- MainTab 탭 선택과 기본 탭(`shortform`), 탭마다 탭바 아이콘(`playStack` · `search` · `chat` · `person` · `plus`), 「만들기」 탭은 보던 탭을 두고 시트를 띄움, 만들기·닫기에 시트 닫기, 시리즈만 실패에 시트 닫고 안내 한 번
- 모임 만들기 Flow: 불러오기·장소 고르기 뒤 입력 채우고 닫기, 포스터 고른 것 들고 있기, 앵콜이면 시리즈 정보 쌓기와 `createEncore`, 시리즈에 묶인 지난 모임이면 그 시리즈로 `create`, 요청 중 다시 누름 무시, 실패 시 시트에 남고 만들기 문구, 시리즈만 실패 알림
- 모임 만들기 화면: 입력의 처음 날짜·시간(다음 5분 칸)과 지난 시각 막기·→ 켜짐 조건·불러온 뒤 채우기·상세 머리말 끼우기(커서 자리, 500자), 장소 검색(검색 키 한 번·0건·체크·실패), 포스터 사진 권한·고르기·배경음악·만들기 사진 입력, 이전 모임 페이지 요청·겹침 거르기·실패, 시리즈 정보 필수 시리즈명
- 딥링크 파싱 (`mozi://home`, https home, unknown)
- 숏폼 쌓기: 견본 「다음」으로 하나 더 쌓이고, 뒤로 가기로 하나씩 빠진다
- 딥링크 `.home`: 메인의 RootFlow → MainTab `openDeepLink` → 숏폼 탭 선택과 쌓인 화면 비우기
- 온보딩: 프로필 「시작하기」 켜짐 조건과 생년월일 목록, 카테고리 받기·5개 상한·저장 성공/실패·저장 중 입력 무시, Flow 쌓기·고른 칸 복원·로그아웃 성공/실패, 「완료」 → OnboardingFlow → RootFlow → main, 보관한 딥링크 처리

## 관련 문서
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [CONVENTIONS.md](../../docs/CONVENTIONS.md)
