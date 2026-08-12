# 스킬 흐름 다이어그램

7개 개발 단계에 걸쳐 스킬들이 어떻게 연결되는지 보여주는 시각적 지도입니다.
각 스킬의 앞뒤로 무엇이 실행되는지, 그리고 스킬 사이에 어떤 산출물이 오가는지를 보여줍니다.

---

## 전체 파이프라인 개요 (제로부터 출시까지)

```
PHASE 1: CONCEPT
  /start ──────────────────────────────────────────────────────► A/B/C/D 로 라우팅
  /brainstorm ──────────────────────────────────────────────────► design/gdd/game-concept.md
  /setup-engine ────────────────────────────────────────────────► CLAUDE.md + technical-preferences.md
  /prototype [core-mechanic] ───────────────────────────────────► prototypes/[name]-concept/REPORT.md
        │ PROCEED                                                  (GDD 작성 전에 아이디어 먼저 검증)
        ▼
  /design-review [game-concept.md] ────────────────────────────► 컨셉 검증됨
  /gate-check ─────────────────────────────────────────────────► PASS → systems-design 단계로 진행
        │
        ▼
PHASE 2: SYSTEMS DESIGN
  /map-systems ────────────────────────────────────────────────► design/gdd/systems-index.md
        │
        ▼ (시스템마다, 의존성 순서대로)
  /design-system [name] ──────────────────────────────────────► design/gdd/[system].md
  /design-review [system].md ─────────────────────────────────► GDD별 리뷰 코멘트
        │
        ▼ (모든 MVP GDD 완료 후)
  /review-all-gdds ────────────────────────────────────────────► design/gdd/gdd-cross-review-[date].md
  /gate-check ─────────────────────────────────────────────────► PASS → technical-setup 단계로 진행
        │
        ▼
PHASE 3: TECHNICAL SETUP
  /create-architecture ────────────────────────────────────────► docs/architecture/master.md
  /architecture-decision (×N) ─────────────────────────────────► docs/architecture/[adr-nnn].md
  /architecture-review ────────────────────────────────────────► 리뷰 리포트 + docs/architecture/tr-registry.yaml
  /create-control-manifest ────────────────────────────────────► docs/architecture/control-manifest.md
  /gate-check ─────────────────────────────────────────────────► PASS → pre-production 단계로 진행
        │
        ▼
PHASE 4: PRE-PRODUCTION
  [UX — 에픽 이전에 진행하여, 스토리 작성 시점에 스펙이 이미 존재하도록]
  /ux-design [screen/hud/patterns] ────────────────────────────► design/ux/*.md
  /ux-review ──────────────────────────────────────────────────► UX 스펙 승인됨 (/team-ui 의 HARD 게이트)

  [테스트 인프라 — 스토리가 테스트를 참조하기 전에 미리 스캐폴딩]
  /test-setup ─────────────────────────────────────────────────► 테스트 프레임워크 + CI/CD 파이프라인
  /test-helpers ───────────────────────────────────────────────► tests/helpers/[engine-specific].gd

  [버티컬 슬라이스 — 에픽 이전에, 전체 게임 루프를 검증]
  /vertical-slice ─────────────────────────────────────────────► prototypes/[name]-vertical-slice/REPORT.md
  /playtest-report ────────────────────────────────────────────► production/playtests/

  [스토리 + 스프린트 계획 — 버티컬 슬라이스가 PROCEED 된 이후에만]
  /create-epics [layer] ───────────────────────────────────────► production/epics/*/EPIC.md
  /create-stories [epic-slug] ─────────────────────────────────► production/epics/*/story-*.md
  /sprint-plan new ────────────────────────────────────────────► production/sprints/sprint-01.md
  /gate-check ─────────────────────────────────────────────────► PASS → production 단계로 진행
        │
        ▼
PHASE 5: PRODUCTION (반복되는 스프린트 루프)
  /sprint-status ──────────────────────────────────────────────► 스프린트 스냅샷
  /story-readiness [story] ────────────────────────────────────► 스토리가 READY 로 검증됨
        │
        ▼ (가져와서 구현)
  /dev-story [story] ──────────────────────────────────────────► 알맞은 프로그래머 에이전트로 라우팅
        │
        ▼ (구현 중, 필요에 따라)
  /code-review ────────────────────────────────────────────────► 코드 리뷰 리포트
  /scope-check ────────────────────────────────────────────────► 스코프 크립 감지됨 / 이상 없음
  /content-audit ──────────────────────────────────────────────► GDD 콘텐츠 격차 식별됨
  /bug-report ─────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
  /bug-triage ─────────────────────────────────────────────────► 버그 우선순위 재조정 + 할당

  [기능 영역별 팀 스킬 — 전체 기능을 작업할 때 스폰]
  /team-combat / /team-narrative / /team-ui / /team-level / /team-audio

  [스프린트별 QA 사이클]
  /qa-plan ────────────────────────────────────────────────────► production/qa/qa-plan-sprint-NN.md
  /smoke-check ────────────────────────────────────────────────► 스모크 테스트 게이트 (PASS/FAIL)
  /regression-suite ───────────────────────────────────────────► 커버리지 격차 + 누락된 회귀 테스트
  /test-evidence-review ───────────────────────────────────────► 증거 품질 리포트
  /test-flakiness ─────────────────────────────────────────────► 불안정한(flaky) 테스트 리포트
        │
        ▼
  /story-done [story] ─────────────────────────────────────────► 스토리 종료 + 다음 스토리 표면화
  /sprint-plan [next] ─────────────────────────────────────────► 다음 스프린트
        │
        ▼ (프로덕션 마일스톤 이후)
  /milestone-review ───────────────────────────────────────────► 마일스톤 리포트
  /gate-check ─────────────────────────────────────────────────► PASS → polish 단계로 진행
        │
        ▼
PHASE 6: POLISH
  /perf-profile ───────────────────────────────────────────────► 퍼포먼스 리포트 + 수정
  /balance-check ──────────────────────────────────────────────► 밸런스 리포트 + 수정
  /asset-audit ────────────────────────────────────────────────► 에셋 준수 리포트
  /tech-debt ──────────────────────────────────────────────────► docs/tech-debt-register.md
  /soak-test ──────────────────────────────────────────────────► 소크 테스트 프로토콜 + 결과
  /localize ───────────────────────────────────────────────────► 로컬라이제이션 준비 리포트
  /team-polish ────────────────────────────────────────────────► 폴리시 스프린트 오케스트레이션
  /team-qa ────────────────────────────────────────────────────► 전체 QA 사이클 사인오프
  /gate-check ─────────────────────────────────────────────────► PASS → release 단계로 진행
        │
        ▼
PHASE 7: RELEASE
  /launch-checklist ───────────────────────────────────────────► 출시 준비 리포트
  /release-checklist ──────────────────────────────────────────► 플랫폼별 체크리스트
  /changelog ──────────────────────────────────────────────────► CHANGELOG.md
  /patch-notes ────────────────────────────────────────────────► 플레이어 대상 노트
  /team-release ───────────────────────────────────────────────► 릴리스 파이프라인 오케스트레이션
        │
        ▼ (출시 이후, 지속적으로)
  /hotfix ─────────────────────────────────────────────────────► 감사 추적이 포함된 긴급 수정
  /team-live-ops ──────────────────────────────────────────────► 라이브 옵스 콘텐츠 계획
```

---

## 스킬 체인: /design-system 상세

하나의 GDD가 어떻게 작성되고, 리뷰되고, 아키텍처로 전달되는지:

```
systems-index.md (입력)
game-concept.md (입력)
상위 GDD (입력, 있는 경우)
        │
        ▼
/design-system [name]
        │
        ├── 사전 점검: 실행 가능성 표 + 엔진 리스크 플래그
        │
        ├── 섹션 사이클 × 8:
        │     질문 → 옵션 → 결정 → 초안 → 승인 → WRITE
        │     [각 섹션은 승인 직후 파일에 기록됨]
        │
        └── 출력: design/gdd/[system].md (완성, 8개 섹션 전부)
                │
                ▼
        /design-review design/gdd/[system].md
                │
                ├── APPROVED → systems-index 에 DONE 표시, 다음 시스템으로 진행
                ├── NEEDS REVISION → 에이전트가 구체적 이슈 제시, 섹션 사이클 재진입
                └── MAJOR REVISION → 다음 시스템 전에 대폭적인 재설계 필요
                        │
                        ▼ (모든 MVP GDD + 크로스 리뷰 이후)
                /review-all-gdds
                        │
                        └── 출력: gdd-cross-review-[date].md
```

---

## 스킬 체인: UX / UI 파이프라인 상세

UX 스펙은 Phase 4(프리프로덕션)에서 에픽 작성 이전에 작성되며, 이를 통해 스토리
수락 기준이 구체적인 UX 산출물을 참조할 수 있습니다.

```
design/gdd/*.md (UI/UX 요구사항 추출됨)
design/player-journey.md (감정 곡선, 작성된 경우)
        │
        ▼
/ux-design hud              → design/ux/hud.md
/ux-design screen [name]    → design/ux/screens/[name].md
/ux-design patterns         → design/ux/interaction-patterns.md
        │
        ▼
/ux-review design/ux/
        │
        ├── APPROVED → UX 스펙 준비 완료, /create-epics 로 진행
        ├── NEEDS REVISION → 차단 이슈 목록 제시 → 수정 → 리뷰 재실행
        └── MAJOR REVISION → 근본적인 UX 문제 → 에픽 전에 재설계
                │
                ▼ (APPROVED 이후 — UI 기능을 구현하는 Phase 5 시점)
        /team-ui
                │
                ├── Phase 1: /ux-design (누락된 스펙이 있는 경우) + /ux-review
                ├── Phase 2: 비주얼 디자인 (art-director)
                ├── Phase 3: 레이아웃 구현 (ui-programmer)
                ├── Phase 4: 접근성 감사 (accessibility-specialist)
                └── Phase 5: 최종 리뷰

Note: /ux-design 와 /ux-review 는 Phase 4(프리프로덕션)에 속합니다.
      /team-ui 는 UI 기능을 구현하는 Phase 5(프로덕션)에 속합니다.
```

---

## 스킬 체인: Dev Story 흐름 상세

스토리가 백로그에서 종료까지 어떻게 이동하는지:

```
/story-readiness [story]
        │
        ├── READY → Status: ready-for-dev → 구현을 위해 가져감
        ├── NEEDS WORK → 에이전트가 구체적 격차 제시 → 해결 → readiness 재실행
        └── BLOCKED → ADR 이 아직 Proposed 상태이거나, 상위 스토리가 미완료
                │
                ▼ (READY 이후)
        /dev-story [story]
                │
                ├── 읽는 것: 스토리 파일, 연결된 GDD 요구사항, ADR 결정사항, control manifest
                ├── 라우팅 대상: gameplay-programmer / engine-programmer / ui-programmer 등
                │
                └── 구현 시작
                        │
                        ▼ (선택 사항, 구현 중/이후)
                /code-review          → 변경분에 대한 아키텍처 리뷰
                /scope-check          → 원래 스토리 기준 대비 스코프 크립 여부 확인
                /test-evidence-review → 테스트 파일 및 수동 증거의 품질 검증
                        │
                        ▼
                /story-done [story]
                        │
                        ├── COMPLETE → Status: Complete, sprint-status.yaml 갱신, 다음 스토리 표면화
                        ├── COMPLETE WITH NOTES → 완료되었으나 일부 기준이 보류됨 (기록됨)
                        └── BLOCKED → 수락 기준을 검증할 수 없음 → 차단 요인 조사
```

---

## 스킬 체인: 스토리 라이프사이클 (백로그에서 종료까지)

스토리가 백로그에서 종료까지 이동하는 과정 (요약 뷰):

```
/create-epics [layer]
        │
        └── 출력: production/epics/[slug]/EPIC.md
                │
                ▼
        /create-stories [epic-slug]
                │
                └── 출력: production/epics/[slug]/story-NNN-[slug].md
                            (Status: ADR 이 Proposed 상태면 Ready 또는 Blocked)
                │
                ▼
        /story-readiness [story]
                │
                ├── READY → /dev-story → 구현 → /story-done
                ├── NEEDS WORK → 격차 해결 → 재실행
                └── BLOCKED → 상위 의존성부터 해결
```

---

## 스킬 체인: QA 파이프라인 상세

```
[Phase 4 — 1회성 인프라 설정]
/test-setup ────────────────────────────────────────────────────► 테스트 프레임워크 스캐폴딩 + CI/CD 연결
/test-helpers ──────────────────────────────────────────────────► tests/helpers/[engine].gd (GDUnit4, NUnit 등)

[Phase 5 — 스프린트별 QA 사이클]
/qa-plan [sprint or feature]
        │
        ├── 읽는 것: 스토리 파일, GDD, 수락 기준
        ├── 각 스토리를 테스트 유형별로 분류:
        │     Logic → 자동화된 단위 테스트 (BLOCKING)
        │     Integration → 통합 테스트 또는 문서화된 플레이테스트 (BLOCKING)
        │     Visual/Feel → 스크린샷 + 리드 사인오프 (ADVISORY)
        │     UI → 수동 워크스루 또는 인터랙션 테스트 (ADVISORY)
        │     Config/Data → 스모크 체크 (ADVISORY)
        └── 출력: production/qa/qa-plan-sprint-NN.md
                │
                ▼
        /smoke-check
                │
                ├── PASS → QA 핸드오프 완료
                └── FAIL → 스프린트 종료 차단 → 크리티컬 패스부터 먼저 수정
                        │
                        ▼
                /regression-suite
                        │
                        └── 커버리지 격차 + 회귀 테스트가 없는 수정된 버그 목록
                                │
                                ▼
                        /test-evidence-review
                                │
                                └── 단순 존재 여부가 아니라 증거의 품질을 검증
                                        │
                                        ▼ (CI 실행 이력이 있는 경우)
                        /test-flakiness
                                │
                                └── 불안정한(flaky) 테스트 리포트 + 수정 권고

[Phase 6 — 확장 안정성 테스트]
/soak-test ─────────────────────────────────────────────────────► 소크 테스트 프로토콜 + 관측 결과
/team-qa ───────────────────────────────────────────────────────► 릴리스 게이트를 위한 전체 QA 사이클 사인오프

[지속 — 버그 관리]
/bug-report ────────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
/bug-triage ────────────────────────────────────────────────────► 열린 버그 우선순위 재조정 + 할당

[Meta — 하네스 검증]
/skill-test [lint|spec|catalog] ────────────────────────────────► 스킬 파일 구조 + 동작 검사
```

---

## 브라운필드 온보딩 흐름

기존 작업물이 있는 프로젝트의 경우 (`/start` 옵션 D 를 사용하거나 직접 실행):

```
/project-stage-detect    → 단계 감지 리포트
        │
        ▼
/adopt
        │
        ├── Phase 1: 존재하는 것 감지
        ├── Phase 2: FORMAT 감사 (단순 존재 여부가 아니라)
        ├── Phase 3: 격차 분류 (BLOCKING / HIGH / MEDIUM / LOW)
        ├── Phase 4: 순서가 정해진 마이그레이션 계획
        ├── Phase 5: docs/adoption-plan-[date].md 작성
        └── Phase 6: 가장 시급한 격차를 즉석에서 수정 (선택 사항)
                │
                ▼
        /design-system retrofit [path]    → 누락된 GDD 섹션 채움
        /architecture-decision retrofit [path] → 누락된 ADR 섹션 채움
        /gate-check                       → 파이프라인 상 현재 위치는?
```

---

## 다이어그램 읽는 법

| 기호 | 의미 |
|--------|---------|
| `──►` | 이 산출물을 생성함 |
| `│ ▼` | 다음 단계로 흐름 |
| `├──` | 분기 (여러 가능한 결과) |
| `×N` | N번 실행 (시스템, 스토리 등 단위마다 1회) |
| `(input)` | 스킬이 읽지만 여기서 생성되지는 않음 |
| `[optional]` | 게이트 통과에 필수는 아님 |
| `WRITE` (대문자) | 파일이 즉시 디스크에 기록됨 |

---

## 자주 쓰는 진입점

| 현재 위치 | 실행할 명령 |
|---------------|---------|
| 완전 처음, 아이디어 없음 | `/start` → `/brainstorm` |
| 컨셉은 있고 엔진이 없음 | `/setup-engine` |
| 컨셉 + 엔진 모두 있음 | `/map-systems` |
| 시스템 설계 진행 중 | `/design-system [next system]` 또는 `/map-systems next` |
| 모든 GDD 완료 | `/review-all-gdds` → `/gate-check` |
| 기술 설정 진행 중 | `/create-architecture` → `/architecture-decision` |
| UX 디자인 시작 단계 | `/ux-design screen [name]` 또는 `/ux-design hud` |
| 테스트 스캐폴딩 중 | `/test-setup` → `/test-helpers` |
| 스토리가 있고 코딩 준비됨 | `/story-readiness [story]` → `/dev-story [story]` |
| 스토리 완료 | `/story-done [story]` |
| 스프린트 QA 진행 중 | `/qa-plan` → `/smoke-check` → `/regression-suite` |
| 버그 백로그 정리 필요 | `/bug-triage` |
| 확장 안정성 테스트 | `/soak-test` |
| 잘 모르겠음 | `/help` |
| 기존 프로젝트 | `/adopt` |
