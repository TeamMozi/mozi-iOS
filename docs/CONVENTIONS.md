# Conventions

구조/의존/흐름은 [ARCHITECTURE.md](ARCHITECTURE.md) 를 본다.
에이전트 실행 절차/hard gate 는 [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) 를 본다.

## Coding
- 들여쓰기 4 spaces
- line length warning 100 / error 120
- force unwrap 금지
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

## Comments
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

## Tests
- 언어: 한국어
- 형식: `test_<상황>_<기대결과>`
- 이름만 보고 상황과 기대 결과가 읽혀야 한다
- 예:
  - `test_홈_커스텀스킴이면_홈으로_파싱`
  - `test_인증_401이면_한_번만_refresh_후_재시도`

## Schemes

| Scheme | Bundle ID |
|---|---|
| `Mozi-Debug` | `com.teamMozi.debug` |
| `Mozi` | `com.teamMozi.app` |

## Git Format
커밋:
```text
Type: 요약
```
Type: feat, fix, docs, style, refactor, test, chore

추가:
- 커밋 본문 금지 (제목만)
- 한 의도 = 한 커밋
- 구현/테스트/문서/설정 분리
- 언어: 한국어

브랜치:
```text
Type/짧은-설명
```

PR 제목:
```text
변경 내용 요약
```

PR 본문 템플릿/작성 규칙:
- 제목/`변경 요약`/`변경 내용` 명사형
- 운영 메타 금지

## Language
- 로컬 문서, 스크립트 주석/usage, 코드 주석, 에이전트 문서: 한국어 기본
- API 이름, 옵션명, 식별자: 영어 유지

## 금지
- Feature 모듈 쪼개기
- AppShell / AppRuntime / AppEnvironment / AppConstants
- Feature → Data / Core* / ThirdPartyCore
- Scene 간 직접 통신
- UseCase 층

## PR 본문 템플릿

```markdown
## 📌 변경 요약
- 
- 
- 

## 📌 변경 내용
#### 
- 

#### 
- 

## 📌 기타 참고 사항
- 
```

**작성 규칙**
- `변경 요약`은 PR 전체를 빠르게 이해하게 3줄 전후로 적는다.
- `변경 내용`은 모듈/영역 단위로 나눈다. 예: Tuist, Domain, Feature, App, Docs
- 각 bullet은 무엇을 바꿨는지 파일/폴더/역할이 보이게 쓴다. 삭제/이동/분리도 명시한다.
- PR 제목/`변경 요약`/`변경 내용` bullet 은 명사형으로 끝낸다.
- `기타 참고 사항` 은 선택 섹션이다. 내용이 없으면 섹션 자체를 삭제한다.
- base/head/브랜치/커밋 해시 같은 운영 메타는 PR 본문에 넣지 않는다.
