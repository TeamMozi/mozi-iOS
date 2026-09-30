---
name: testflight
description: Use when the Mozi app build is to be uploaded to TestFlight for the team — "테플 올려", "TestFlight 올려", "팀원한테 빌드 보내", "/testflight <문구>". Takes one line of "테스트할 항목" text as the argument. Not for App Store submission.
---

# testflight

본 앱을 TestFlight 「모지 팀」 그룹에 올린다. 절차 본문은 `fastlane/Fastfile` 의 `beta` 와 `resume` 이다.

## 받을 것

- 문구 한 줄: 팀원이 이번 빌드에서 볼 것. 인자로 오지 않았으면 먼저 묻는다. 커밋 해시는 절차가 붙인다.

## 실행 전 확인

1. `fastlane/.env` 가 있어야 한다. 없으면 `fastlane/.env.example` 을 복사해 값을 채우라고 알리고 멈춘다.
2. 지금 커밋이 push 되어 있어야 한다. 절차가 확인하지만, 안 되어 있으면 실행 전에 알린다.

## 실행

빌드가 10분을 넘길 수 있으므로 Bash 의 `run_in_background: true` 로 돌린다.

```bash
mkdir -p build
set -o pipefail; mise exec -- bundle exec fastlane beta app:mozi note:"<문구>" 2>&1 | tee "build/testflight-$(date +%Y%m%d-%H%M%S).log"
```

## 끝난 뒤

- 성공: 로그의 `빌드 번호 ... 문구: ...` 줄에서 번호와 문구를 보고한다.
- 업로드 뒤 실패: 로그에서 `이어가기 명령:` 줄을 찾아 그 명령을 보여 주고, 돌릴지 묻는다. 아카이브를 다시 하지 않고 번호도 늘지 않는다.
- 업로드 전 실패: 마지막 오류 줄 하나를 인용하고 원인을 보고한다.
