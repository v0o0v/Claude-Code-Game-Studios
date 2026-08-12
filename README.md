<p align="center">
  <h1 align="center">Claude Code Game Studios</h1>
  <p align="center">
    하나의 Claude Code 세션을 완전한 게임 개발 스튜디오로 바꾸는 플러그인.
    <br />
    56개 에이전트. 74개 스킬. 클론 없이 설치 한 번으로.
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href="plugin/agents"><img src="https://img.shields.io/badge/agents-56-blueviolet" alt="56 Agents"></a>
  <a href="plugin/skills"><img src="https://img.shields.io/badge/skills-74-green" alt="74 Skills"></a>
  <a href="plugin/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="plugin/engine-reference"><img src="https://img.shields.io/badge/engines-4-teal" alt="4 Engine Packs"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## 목차

1. [소개](#1-소개)
2. [설치 및 사용법](#2-설치-및-사용법)
3. [전체 사용 워크플로](#3-전체-사용-워크플로)
4. [에이전트 · 스킬 · 훅](#4-에이전트--스킬--훅)
5. [기타](#5-기타)

---

## 1. 소개

AI와 함께 혼자 게임을 만드는 것은 강력하지만, 단일 채팅 세션에는 구조가 없습니다. 매직 넘버를 하드코딩하거나, 디자인 문서를 건너뛰거나, 스파게티 코드를 작성하는 것을 막아줄 사람이 없습니다. QA 패스도, 디자인 리뷰도, "이게 정말 게임의 비전에 맞는가?"라고 물어봐줄 사람도 없습니다.

**Claude Code Game Studios(`ccgs`)**는 Claude Code 세션에 실제 스튜디오의 구조를 부여함으로써 이 문제를 해결하는 **플러그인**입니다. 하나의 범용 어시스턴트 대신, 스튜디오 계층구조로 조직된 56개의 전문 에이전트를 얻게 됩니다:

```
Tier 1 — Directors      비전을 지키고 최종 승인을 내리는 디렉터 3명
Tier 2 — Dept. Leads    자신의 도메인(디자인/코드/아트/오디오/내러티브/QA/릴리스)을 책임지는 리드 8명
Tier 3 — Specialists    실무를 수행하는 프로그래머·디자이너·아티스트 전문가 45명
```

각 에이전트는 명확한 책임, 에스컬레이션 경로, 품질 게이트를 가지고 있습니다. 모든 결정은 여전히 사용자가 내리지만, 이제는 올바른 질문을 던지고, 실수를 조기에 발견하고, 첫 브레인스토밍부터 출시까지 프로젝트를 체계적으로 유지해주는 팀이 생기는 것입니다.

리포를 클론하거나 파일을 복사할 필요가 없습니다 — `claude plugin install` 한 번이면 **어느 게임 프로젝트 디렉터리에서든** `/ccgs:brainstorm`, `/ccgs:setup-engine` 같은 명령을 바로 쓸 수 있습니다.

## 2. 설치 및 사용법

### 사전 준비물

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)만 있으면 됩니다. Git이나 별도 도구는 필요 없습니다.

### 설치

```bash
claude plugin marketplace add v0o0v/Claude-Code-Game-Studios
```

```bash
claude plugin install ccgs@ccgs-marketplace
```

### 프로젝트에서 시작하기

게임 프로젝트로 쓸 디렉터리에서 Claude Code를 엽니다:

```bash
claude
```

프로젝트를 처음 초기화한다면:

```
/ccgs:init
```

무엇을 만들지 먼저 설명하고 승인을 받은 뒤에만 씁니다 — 디렉터리 구조(`design/`, `production/`, `tests/` 등), `.claude/docs/` 참조 문서, `.claude/rules/` 코딩 규칙, `CLAUDE.md`의 협업 프로토콜 블록과 `Technology Stack` 플레이스홀더를 만듭니다.

그다음:

```
/ccgs:setup-engine
```

엔진(Godot / Unity / Unreal Engine 5 / Web)과 버전을 정하면, 플러그인에 번들된 해당 엔진의 레퍼런스 문서 팩을 프로젝트로 복사하고 `technical-preferences.md`를 채웁니다.

여기서부터는 [전체 사용 워크플로](#3-전체-사용-워크플로)를 따라가면 됩니다. 이미 뭘 해야 할지 안다면 바로 특정 스킬로 이동해도 됩니다 — `/ccgs:brainstorm`(아이디어부터), `/ccgs:project-stage-detect`(기존 프로젝트 분석) 등.

모든 스킬은 `/ccgs:<이름>`, 모든 에이전트는 `ccgs:<이름>` 형태의 네임스페이스로 호출됩니다. 어느 프로젝트를 열어도 동일하게 동작합니다.

## 3. 전체 사용 워크플로

프로젝트는 7개 페이즈를 거칩니다. 각 페이즈는 다음 페이즈로 넘어가기 전에 확인할 산출물이 있습니다:

```
Concept ──▶ Systems Design ──▶ Technical Setup ──▶ Pre-Production
                                                          │
Release ◀── Polish ◀── Production ◀──────────────────────┘
```

| 페이즈 | 산출물 |
|---|---|
| **Concept** | 게임 컨셉 문서, 핵심 필러 |
| **Systems Design** | 시스템 인덱스, 개별 시스템 GDD |
| **Technical Setup** | 아키텍처 문서, ADR, 테스트/CI 스캐폴드 |
| **Pre-Production** | 에픽·스토리, 버티컬 슬라이스 검증 |
| **Production** | 스프린트별 실제 구현, 코드 리뷰 |
| **Polish** | 성능·QA·회귀 테스트 |
| **Release** | 릴리스 체크리스트, 패치 노트, 출시 |

실제 명령어 시퀀스로 보면:

```
/ccgs:init                              # 프로젝트 스캐폴드
/ccgs:setup-engine godot 4.6            # 엔진 고정
/ccgs:brainstorm                        # 게임 컨셉 확정
/ccgs:map-systems                       # 시스템 목록·의존성·우선순위
/ccgs:design-system [system-name]       # 시스템별 GDD (반복)
/ccgs:create-architecture               # 기술 아키텍처 문서
/ccgs:architecture-decision [title]     # 필요한 ADR (반복)
/ccgs:create-epics                      # GDD+아키텍처 → 에픽
/ccgs:create-stories [epic]             # 에픽 → 구현 가능한 스토리
/ccgs:dev-story [story]                 # 스토리 구현
/ccgs:story-done [story]                # 완료 검증 + 다음 스토리 안내
/ccgs:gate-check [phase]                # 페이즈 전환 게이트
/ccgs:release-checklist                 # 출시 준비 검증
```

각 스킬은 진행하기 전에 항상 **질문 → 옵션 제시 → 사용자 결정 → 초안 → 승인** 순서를 따릅니다 — 자동조종(오토파일럿)이 아닙니다.

> **리뷰 강도**: 기본은 `lean`(단계 게이트만 확인)입니다. 모든 디렉터의 승인을 받고 싶다면 `--review full`을, 혼자 빠르게 진행하고 싶다면 `--review solo`를 스킬 실행 시 붙이세요. `production/review-mode.txt`를 편집하면 프로젝트 기본값을 바꿀 수 있습니다.

## 4. 에이전트 · 스킬 · 훅

### 에이전트 (56개)

```
Tier 1 — Directors (Opus)
  ccgs:creative-director    ccgs:technical-director    ccgs:producer

Tier 2 — Department Leads (Sonnet)
  ccgs:game-designer        ccgs:lead-programmer        ccgs:art-director
  ccgs:audio-director       ccgs:narrative-director      ccgs:qa-lead
  ccgs:release-manager      ccgs:localization-lead

Tier 3 — Specialists (Sonnet/Haiku)
  ccgs:gameplay-programmer  ccgs:engine-programmer       ccgs:ai-programmer
  ccgs:network-programmer   ccgs:tools-programmer        ccgs:ui-programmer
  ccgs:systems-designer     ccgs:level-designer          ccgs:economy-designer
  ccgs:technical-artist     ccgs:sound-designer          ccgs:writer
  ccgs:world-builder        ccgs:ux-designer             ccgs:prototyper
  ccgs:performance-analyst  ccgs:devops-engineer         ccgs:analytics-engineer
  ccgs:security-engineer    ccgs:qa-tester               ccgs:accessibility-specialist
  ccgs:live-ops-designer    ccgs:community-manager
```

**엔진 전문가** — `/ccgs:setup-engine`으로 고른 엔진에 맞는 세트가 자동으로 라우팅됩니다:

| 엔진 | 리드 에이전트 | 서브 전문가 |
|---|---|---|
| **Godot 4** | `ccgs:godot-specialist` | GDScript, C#, 셰이더, GDExtension |
| **Unity** | `ccgs:unity-specialist` | DOTS/ECS, 셰이더/VFX, Addressables, UI Toolkit |
| **Unreal Engine 5** | `ccgs:unreal-specialist` | GAS, Blueprint, 리플리케이션, UMG/CommonUI |
| **Web** | `ccgs:web-specialist` | PixiJS, Three.js, TypeScript, 셰이더, 배포 |

에이전트는 구조화된 위임 모델을 따릅니다: 디렉터는 리드에게, 리드는 전문가에게 위임하고(**수직 위임**), 같은 티어끼리는 협의는 하되 구속력 있는 결정은 내리지 않으며(**수평 협의**), 의견 충돌은 공통 상위 에이전트로 올라갑니다(디자인은 `ccgs:creative-director`, 기술은 `ccgs:technical-director`).

### 스킬 (74개)

`/`를 입력하면 74개 스킬 전체에 접근할 수 있습니다:

**온보딩 및 내비게이션**
`/ccgs:init` `/ccgs:start` `/ccgs:help` `/ccgs:project-stage-detect` `/ccgs:setup-engine` `/ccgs:adopt`

**게임 디자인**
`/ccgs:brainstorm` `/ccgs:map-systems` `/ccgs:design-system` `/ccgs:quick-design` `/ccgs:review-all-gdds` `/ccgs:propagate-design-change`

**아트 및 에셋**
`/ccgs:art-bible` `/ccgs:asset-spec` `/ccgs:asset-audit`

**UX 및 인터페이스 디자인**
`/ccgs:ux-design` `/ccgs:ux-review`

**아키텍처**
`/ccgs:create-architecture` `/ccgs:architecture-decision` `/ccgs:architecture-review` `/ccgs:create-control-manifest`

**스토리 및 스프린트**
`/ccgs:create-epics` `/ccgs:create-stories` `/ccgs:dev-story` `/ccgs:sprint-plan` `/ccgs:sprint-status` `/ccgs:story-readiness` `/ccgs:story-done` `/ccgs:estimate`

**리뷰 및 분석**
`/ccgs:design-review` `/ccgs:code-review` `/ccgs:balance-check` `/ccgs:content-audit` `/ccgs:scope-check` `/ccgs:perf-profile` `/ccgs:tech-debt` `/ccgs:gate-check` `/ccgs:consistency-check` `/ccgs:security-audit`

**QA 및 테스트**
`/ccgs:qa-plan` `/ccgs:smoke-check` `/ccgs:soak-test` `/ccgs:regression-suite` `/ccgs:test-setup` `/ccgs:test-helpers` `/ccgs:test-evidence-review` `/ccgs:test-flakiness` `/ccgs:skill-test` `/ccgs:skill-improve`

**프로덕션**
`/ccgs:milestone-review` `/ccgs:retrospective` `/ccgs:bug-report` `/ccgs:bug-triage` `/ccgs:reverse-document` `/ccgs:playtest-report`

**릴리스**
`/ccgs:release-checklist` `/ccgs:launch-checklist` `/ccgs:changelog` `/ccgs:patch-notes` `/ccgs:hotfix` `/ccgs:day-one-patch`

**크리에이티브 및 콘텐츠**
`/ccgs:prototype` `/ccgs:onboard` `/ccgs:localize`

**팀 오케스트레이션** (하나의 기능에 여러 에이전트를 조율)
`/ccgs:team-combat` `/ccgs:team-narrative` `/ccgs:team-ui` `/ccgs:team-release` `/ccgs:team-polish` `/ccgs:team-audio` `/ccgs:team-level` `/ccgs:team-live-ops` `/ccgs:team-qa`

`/ccgs:vertical-slice` — 프리-프로덕션에서 Production으로 넘어가기 전, 전체 게임 루프가 실제로 재미있는지 검증하는 프로덕션 품질의 엔드투엔드 빌드를 만듭니다.

### 훅 (1개)

| 훅 | 트리거 | 동작 |
|---|---|---|
| `session-start` | `SessionStart` | 프로젝트에 `.ccgs/config.yaml` 마커가 있으면 누락된 디렉터리·문서를 자동 복구. 마커가 없으면(아직 `/ccgs:init`을 안 한 프로젝트) 힌트 한 줄만 출력하고 아무것도 쓰지 않습니다 — 무관한 프로젝트를 열어도 안전합니다. |

## 5. 기타

### 디자인 철학

이 플러그인의 에이전트·스킬은 전문적인 게임 개발 실무에 기반합니다:

- **MDA 프레임워크** — 게임 디자인을 위한 메커닉스, 다이내믹스, 미학 분석
- **자기결정이론(Self-Determination Theory)** — 플레이어 동기부여를 위한 자율성, 유능감, 관계성
- **플로우 상태 디자인** — 플레이어 몰입을 위한 도전-실력 균형
- **바틀 플레이어 유형(Bartle Player Types)** — 타깃 유저층 설정 및 검증
- **검증 주도 개발(Verification-Driven Development)** — 테스트를 먼저, 구현은 그다음

### 업데이트

```bash
claude plugin marketplace update ccgs-marketplace
```
```bash
claude plugin install ccgs@ccgs-marketplace
```

`claude plugin details ccgs@ccgs-marketplace`로 현재 설치된 버전과 컴포넌트 목록을 확인할 수 있습니다.

### 로컬에서 포크 개발하기

플러그인 자체를 수정하며 테스트하려면(에이전트 프롬프트 조정, 새 스킬 추가 등), 원격 대신 로컬 경로로 마켓플레이스를 등록하세요:

```bash
git clone https://github.com/v0o0v/Claude-Code-Game-Studios.git
```
```bash
claude plugin marketplace add ./Claude-Code-Game-Studios
```
```bash
claude plugin install ccgs@ccgs-marketplace
```

이후 리포 파일을 수정하고 `claude plugin marketplace update ccgs-marketplace` → 재설치하면 변경사항이 반영됩니다.

### 플랫폼 지원

플러그인 훅은 POSIX 호환 bash 스크립트로 작성되어 있어 Windows(Git Bash)·macOS·Linux에서 모두 동작합니다. 주 개발 및 테스트는 Windows 10 + Git Bash 환경에서 이루어지고 있으며, 다른 플랫폼에서 문제가 발견되면 이슈로 등록해 주세요.

지원 엔진은 Godot 4, Unity, Unreal Engine 5, Web(PixiJS/Three.js) 네 가지이며 `/ccgs:setup-engine` 중에 선택합니다.

### 커뮤니티

- **Discussions** — 질문, 아이디어 공유, 완성한 결과물 소개를 위한 [GitHub Discussions](https://github.com/v0o0v/Claude-Code-Game-Studios/discussions)
- **Issues** — [버그 리포트 및 기능 요청](https://github.com/v0o0v/Claude-Code-Game-Studios/issues)

### 라이선스

MIT 라이선스입니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.

---

*Claude Code를 위해 제작되었습니다. 지속적으로 유지보수 및 확장되고 있으며 — [GitHub Discussions](https://github.com/v0o0v/Claude-Code-Game-Studios/discussions)를 통한 기여를 환영합니다.*
