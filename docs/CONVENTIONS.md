# Conventions

구조·의존·앱 흐름은 [ARCHITECTURE.md](ARCHITECTURE.md) 를 본다.
모듈 내부 규칙과 진입점은 각 `Projects/**/README.md` 를 본다.

---

## a. 코딩

포맷과 안전성은 [.swiftlint.yml](../.swiftlint.yml) 이 유일본이다. 그 파일이 검사하는 규칙은 이 문서에 다시 적지 않는다.

예외가 하나 있다. 들여쓰기는 4 spaces 를 쓴다. SwiftLint 의 `indentation_width` 규칙은 여는 구문에 맞춘 정렬 들여쓰기를 위반으로 잡기 때문에 켜지 않는다.

### 1. 모듈과 타입

- Feature 단일 모듈, 기능 분리는 폴더
- Scene 내부 flat (`*Feature`, `*View`)
- Domain 포트는 `*Client`
- Data 구현은 `*RepositoryImpl` + `*ClientFactory` + `*Client.live`
- live 구현 제공은 Data, live 등록/주입은 App only
- Feature 는 Domain `*Client` 만 사용
- Scene 통신은 delegate bubble-up
- SharedUtils 는 pure Foundation / App metadata 만. UI·I/O·Domain 금지
- CoreNetwork 는 SharedLogger (`.network`) 를 쓰고 service-specific domain flow 를 넣지 않는다
- SharedDesignSystem은 Feature에서 `Color.ds` / `Font.ds` / `CGFloat.ds` / `TextStyle.ds` 와 공통 컴포넌트만 사용. Primitive 직접 참조 금지

### 2. 주석

기본: 주석 최소화. 무분별한 주석 금지.

허용:
1. 복잡한 로직의 의도/함정
2. 설명이 필요한 객체
3. 현재 구현 범위 밖 후속 구현 TODO

역할:
- `//` : 복잡한 로직, 함정, TODO
- `///` : 타입/포트/공개 계약

TODO:
- 형식: `// TODO: ...`
- 지금 구현하지 않지만 추후 필요한 지점만
- 이슈 번호/소유자 강제 없음

금지:
- 자명한 코드 설명
- 진행 잡담형 주석

좋은 예:
```swift
// 이미 다른 요청이 refresh를 끝낸 뒤라면 중복 refresh 없이 재시도한다.
/// Domain 포트. Feature는 이 Client만 의존한다.
// TODO: AuthClient 연결
```

### 3. 테스트

- 언어: 한국어
- 형식: `test_<상황>_<기대결과>`
- 이름만 보고 상황과 기대 결과가 읽혀야 한다
- 예:
  - `test_홈_커스텀스킴이면_홈으로_파싱`
  - `test_인증_401이면_한_번만_refresh_후_재시도`

### 4. Scheme

| Scheme | Bundle ID |
|---|---|
| `Mozi-Debug` | `com.teamMozi.debug` |
| `Mozi` | `com.teamMozi.app` |

### 5. 언어

- 로컬 문서, 스크립트 주석/usage, 코드 주석, 에이전트 문서: 한국어 기본
- API 이름, 옵션명, 식별자: 영어 유지

### 6. 금지

- Feature 모듈 쪼개기
- AppShell / AppRuntime / AppEnvironment / AppConstants
- Feature → Data / Core* / ThirdPartyCore
- Scene 간 직접 통신
- UseCase 층

---

## b. 커밋

형식:

```text
Type: 요약
```

Type: feat, fix, docs, style, refactor, test, chore

- 커밋 본문 금지 (제목만)
- 한 의도 = 한 커밋
- 구현/테스트/문서/설정 분리
- 언어: 한국어

---

## c. 브랜치와 PR

브랜치 이름:

```text
Type/짧은-설명
```

PR 제목:

```text
변경 내용 요약
```

PR 본문은 [.github/pull_request_template.md](../.github/pull_request_template.md) 를 채운다. 작성 규칙은 아래와 같다.

- `변경 요약`은 PR 전체를 빠르게 이해하게 3줄 전후로 적는다.
- `변경 내용`은 모듈/영역 단위로 나눈다. 예: Tuist, Domain, Feature, App, Docs
- 각 bullet은 무엇을 바꿨는지 파일/폴더/역할이 보이게 쓴다. 삭제/이동/분리도 명시한다.
- PR 제목/`변경 요약`/`변경 내용` bullet 은 명사형으로 끝낸다.
- `기타 참고 사항` 은 선택 섹션이다. 내용이 없으면 섹션 자체를 삭제한다.
- base/head/브랜치/커밋 해시 같은 운영 메타는 PR 본문에 넣지 않는다.

---

## d. 관련

- [ARCHITECTURE.md](ARCHITECTURE.md)
- [../AGENTS.md](../AGENTS.md)
- [.swiftlint.yml](../.swiftlint.yml)
- [.coderabbit.yaml](../.coderabbit.yaml)
- [.github/pull_request_template.md](../.github/pull_request_template.md)
