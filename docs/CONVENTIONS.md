# Conventions

구조/의존/흐름은 [ARCHITECTURE.md](ARCHITECTURE.md) 를 본다.

## Coding

- 들여쓰기 4 spaces
- line length warning 100 / error 120
- force unwrap 금지
- Feature 단일 모듈, 기능 분리는 폴더
- Domain 포트는 `*Client`
- Data 구현은 `*RepositoryImpl` + `*ClientFactory`
- live 조립은 App only
- Scene 통신은 delegate bubble-up
- SharedUtils는 pure Foundation / App metadata 만. UI·I/O·Domain 금지

## Schemes

| Scheme | Bundle ID |
|---|---|
| `Mozi-Debug` | `com.teamMozi.debug` |
| `Mozi` | `com.teamMozi.app` |

## Git

커밋:

```text
Type: 요약
```

Type: feat, fix, docs, style, refactor, test, chore

브랜치:

```text
Type/짧은-설명
```

예:

```text
feat/placeholder-runtime
chore/setup-project
```

PR 제목:

```text
변경 내용 요약
```

예:

```text
placeholder 런타임 추가
placeholder 런타임 정리
```

PR 본문:

```markdown
## 📌 변경 요약
- 한 줄 요약 1
- 한 줄 요약 2
- 한 줄 요약 3

## 📌 변경 내용
#### 영역 A
- 구체 변경 1
- 구체 변경 2

#### 영역 B
- 구체 변경 1
```

작성 규칙:

- `변경 요약`은 PR 전체를 빠르게 이해하게 3줄 전후로 적는다.
- `변경 내용`은 모듈/영역 단위로 나눈다. 예: Tuist, Domain, Feature, App, Docs
- 각 bullet은 무엇을 바꿨는지 파일/폴더/역할이 보이게 쓴다.
- 삭제/이동/분리도 명시한다.


## 금지

- Feature 모듈 쪼개기
- AppShell / AppRuntime / AppEnvironment / AppConstants
- Feature → Data / Core* / ThirdPartyCore
- Scene 간 직접 통신
- UseCase 층
