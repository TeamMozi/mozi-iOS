---
name: testflight
description: Use when a Mozi build is to be uploaded to TestFlight for the team — the main app, the demo app 「모지 데모」, or both — "테플 올려", "TestFlight 올려", "데모 앱 올려", "팀원한테 빌드 보내", "/testflight <앱> <문구>". Takes the app (mozi, demo, or both) and one line of "테스트할 항목" text. Not for App Store submission.
---

# testflight

본 앱은 TestFlight 「모지 팀」 그룹에, 데모 앱 「모지 데모」는 「모지 데모 팀」 그룹에 올린다. 절차 본문은 `fastlane/Fastfile` 의 `beta` 와 `resume` 이다.

## 받을 것

- 앱: `mozi`(본 앱), `demo`(데모 앱), 둘 다 중 하나. 인자로 오지 않았으면 먼저 묻는다. 선택지는 본 앱 / 데모 앱 / 둘 다 셋이다. 두 그룹의 받는 사람이 달라서 짐작으로 고르지 않는다.
- 문구 한 줄: 팀원이 이번 빌드에서 볼 것. 인자로 오지 않았으면 먼저 묻는다. 커밋 해시는 절차가 붙인다. 데모 앱은 이 문구(해시 포함)를 첫 화면 「이번 빌드에서 바뀐 것」 칸에 보인다.

## 실행 전 확인

1. `fastlane/.env` 가 있어야 한다. 없으면 `fastlane/.env.example` 을 복사해 값을 채우라고 알리고 멈춘다.
2. 지금 커밋이 push 되어 있어야 한다. 절차가 확인하지만, 안 되어 있으면 실행 전에 알린다.

## 실행

빌드가 10분을 넘길 수 있으므로 Bash 의 `run_in_background: true` 로 돌린다. `<앱>` 자리에 `mozi` 나 `demo` 를 넣는다.
문구는 작은따옴표로 감싸고, 문구 안의 `'` 는 `'\''` 로 바꿔 넣는다. 큰따옴표로 감싸면 셸이 `$`·백틱·`"` 를 먼저 해석해 문구가 깨진다.

```bash
mkdir -p build
set -o pipefail; mise exec -- bundle exec fastlane beta app:<앱> note:'<문구>' 2>&1 | tee "build/testflight-<앱>-$(date +%Y%m%d-%H%M%S).log"
```

둘 다면 같은 문구로 `mozi` 를 먼저 올리고, 끝난 뒤 `demo` 를 올린다. 두 명령을 동시에 돌리지 않는다. 같은 빌드 폴더를 쓴다.
`mozi` 가 실패하면 `demo` 를 돌리지 않고 아래 「끝난 뒤」대로 보고한다.

## 끝난 뒤

- 성공: 로그의 `빌드 번호 ... 문구: ...` 줄에서 앱, 번호, 문구를 보고한다.
- 업로드 뒤 실패: 로그에서 `이어가기 명령:` 줄을 찾아 그 명령을 보여 주고, 돌릴지 묻는다. 아카이브를 다시 하지 않고 번호도 늘지 않는다. 이어가기에서 문구를 고쳐 쓰면 데모 앱 안 문구와 알림 문구가 달라진다.
- 업로드 전 실패: 마지막 오류 줄 하나를 인용하고 원인을 보고한다.
