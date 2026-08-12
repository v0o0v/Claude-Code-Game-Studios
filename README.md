<p align="center">
  <h1 align="center">Claude Code Game Studios</h1>
  <p align="center">
    하나의 Claude Code 세션을 완전한 게임 개발 스튜디오로 바꿔보세요.
    <br />
    56개 에이전트. 73개 스킬. 하나로 조율되는 AI 팀.
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-56-blueviolet" alt="56 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-73-green" alt="73 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-12-orange" alt="12 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## 이 프로젝트가 존재하는 이유

AI와 함께 혼자 게임을 만드는 것은 강력하지만, 단일 채팅 세션에는 구조가 없습니다. 매직 넘버를 하드코딩하거나, 디자인 문서를 건너뛰거나, 스파게티 코드를 작성하는 것을 막아줄 사람이 없습니다. QA 패스도, 디자인 리뷰도, "이게 정말 게임의 비전에 맞는가?"라고 물어봐줄 사람도 없습니다.

**Claude Code Game Studios**는 AI 세션에 실제 스튜디오의 구조를 부여함으로써 이 문제를 해결합니다. 하나의 범용 어시스턴트 대신, 스튜디오 계층구조로 조직된 56개의 전문 에이전트를 얻게 됩니다 — 비전을 지키는 디렉터, 자신의 도메인을 책임지는 부서 리드, 실무를 수행하는 전문가들입니다. 각 에이전트는 명확한 책임, 에스컬레이션 경로, 품질 게이트를 가지고 있습니다.

결과적으로: 모든 결정은 여전히 사용자가 내리지만, 이제는 올바른 질문을 던지고, 실수를 조기에 발견하고, 첫 브레인스토밍부터 출시까지 프로젝트를 체계적으로 유지해주는 팀이 생기는 것입니다.

---

## 목차

- [포함된 것](#포함된-것)
- [스튜디오 계층구조](#스튜디오-계층구조)
- [슬래시 명령어](#슬래시-명령어)
- [시작하기](#시작하기)
- [업그레이드](#업그레이드)
- [프로젝트 구조](#프로젝트-구조)
- [작동 방식](#작동-방식)
- [디자인 철학](#디자인-철학)
- [커스터마이징](#커스터마이징)
- [플랫폼 지원](#플랫폼-지원)
- [커뮤니티](#커뮤니티)
- [라이선스](#라이선스)

---

## 포함된 것

| 분류 | 개수 | 설명 |
|----------|-------|-------------|
| **에이전트** | 56 | 디자인, 프로그래밍, 아트, 오디오, 내러티브, QA, 프로덕션 전반에 걸친 전문 서브에이전트 |
| **스킬** | 73 | 모든 워크플로 단계를 위한 슬래시 명령어(`/start`, `/design-system`, `/create-epics`, `/create-stories`, `/dev-story`, `/story-done` 등) |
| **훅** | 12 | 커밋, 푸시, 에셋 변경, 세션 라이프사이클, 에이전트 감사 추적, 갭 감지에 대한 자동 검증 |
| **규칙** | 11 | 게임플레이, 엔진, AI, UI, 네트워크 코드 등을 편집할 때 적용되는 경로 기반 코딩 표준 |
| **템플릿** | 41 | GDD, UX 명세, ADR, 스프린트 계획, HUD 디자인, 접근성 등을 위한 문서 템플릿 |

## 스튜디오 계층구조

에이전트는 실제 스튜디오가 운영되는 방식에 맞춰 세 개의 티어로 구성됩니다:

```
Tier 1 — Directors (Opus)
  creative-director    technical-director    producer

Tier 2 — Department Leads (Sonnet)
  game-designer        lead-programmer       art-director
  audio-director       narrative-director    qa-lead
  release-manager      localization-lead

Tier 3 — Specialists (Sonnet/Haiku)
  gameplay-programmer  engine-programmer     ai-programmer
  network-programmer   tools-programmer      ui-programmer
  systems-designer     level-designer        economy-designer
  technical-artist     sound-designer        writer
  world-builder        ux-designer           prototyper
  performance-analyst  devops-engineer       analytics-engineer
  security-engineer    qa-tester             accessibility-specialist
  live-ops-designer    community-manager
```

### 엔진 전문가

템플릿에는 3대 주요 엔진 모두에 대한 에이전트 세트가 포함되어 있습니다. 프로젝트에 맞는 세트를 사용하세요:

| 엔진 | 리드 에이전트 | 서브 전문가 |
|--------|-----------|-----------------|
| **Godot 4** | `godot-specialist` | GDScript, 셰이더, GDExtension |
| **Unity** | `unity-specialist` | DOTS/ECS, 셰이더/VFX, Addressables, UI Toolkit |
| **Unreal Engine 5** | `unreal-specialist` | GAS, Blueprint, 리플리케이션, UMG/CommonUI |

## 슬래시 명령어

Claude Code에서 `/`를 입력하면 73개의 스킬 전체에 접근할 수 있습니다:

**온보딩 및 내비게이션**
`/start` `/help` `/project-stage-detect` `/setup-engine` `/adopt`

**게임 디자인**
`/brainstorm` `/map-systems` `/design-system` `/quick-design` `/review-all-gdds` `/propagate-design-change`

**아트 및 에셋**
`/art-bible` `/asset-spec` `/asset-audit`

**UX 및 인터페이스 디자인**
`/ux-design` `/ux-review`

**아키텍처**
`/create-architecture` `/architecture-decision` `/architecture-review` `/create-control-manifest`

**스토리 및 스프린트**
`/create-epics` `/create-stories` `/dev-story` `/sprint-plan` `/sprint-status` `/story-readiness` `/story-done` `/estimate`

**리뷰 및 분석**
`/design-review` `/code-review` `/balance-check` `/content-audit` `/scope-check` `/perf-profile` `/tech-debt` `/gate-check` `/consistency-check` `/security-audit`

**QA 및 테스트**
`/qa-plan` `/smoke-check` `/soak-test` `/regression-suite` `/test-setup` `/test-helpers` `/test-evidence-review` `/test-flakiness` `/skill-test` `/skill-improve`

**프로덕션**
`/milestone-review` `/retrospective` `/bug-report` `/bug-triage` `/reverse-document` `/playtest-report`

**릴리스**
`/release-checklist` `/launch-checklist` `/changelog` `/patch-notes` `/hotfix` `/day-one-patch`

**크리에이티브 및 콘텐츠**
`/prototype` `/onboard` `/localize`

**팀 오케스트레이션** (하나의 기능에 여러 에이전트를 조율)
`/team-combat` `/team-narrative` `/team-ui` `/team-release` `/team-polish` `/team-audio` `/team-level` `/team-live-ops` `/team-qa`

## 시작하기

### 사전 준비물

- [Git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- **권장**: [jq](https://jqlang.github.io/jq/) (훅 검증용) 및 Python 3 (JSON 검증용)

선택적 도구가 없어도 모든 훅은 정상적으로 실패 처리됩니다 — 아무것도 깨지지 않으며, 단지 검증 기능만 빠집니다.

### 설정

1. **클론하거나 템플릿으로 사용**:
   ```bash
   git clone https://github.com/Donchitos/Claude-Code-Game-Studios.git my-game
   cd my-game
   ```

2. **Claude Code를 열고** 세션을 시작합니다:
   ```bash
   claude
   ```

3. **`/start`를 실행하세요** — 시스템이 현재 상황(아이디어 없음, 막연한 컨셉, 명확한 디자인, 기존 작업물)을 물어보고 알맞은 워크플로로 안내합니다. 아무것도 가정하지 않습니다.

   이미 필요한 것을 알고 있다면 특정 스킬로 바로 이동해도 됩니다:
   - `/brainstorm` — 처음부터 게임 아이디어 탐색
   - `/setup-engine godot 4.6` — 이미 알고 있다면 엔진 설정
   - `/project-stage-detect` — 기존 프로젝트 분석

## 업그레이드

이미 이 템플릿의 이전 버전을 사용 중이신가요? 단계별 마이그레이션 안내, 버전 간 변경 사항 정리, 그리고 덮어써도 안전한 파일과 수동 병합이 필요한 파일 구분은 [UPGRADING.md](UPGRADING.md)를 참고하세요.

## 프로젝트 구조

```
CLAUDE.md                           # Master configuration
.claude/
  settings.json                     # Hooks, permissions, safety rules
  agents/                           # 56 agent definitions (markdown + YAML frontmatter)
  skills/                           # 73 slash commands (subdirectory per skill)
  hooks/                            # 12 hook scripts (bash, cross-platform)
  rules/                            # 11 path-scoped coding standards
  statusline.sh                     # Status line script (context%, model, stage, epic breadcrumb)
  docs/
    workflow-catalog.yaml           # 7-phase pipeline definition (read by /help)
    templates/                      # 41 document templates
src/                                # Game source code
assets/                             # Art, audio, VFX, shaders, data files
design/                             # GDDs, narrative docs, level designs
docs/                               # Technical documentation and ADRs
tests/                              # Test suites (unit, integration, performance, playtest)
tools/                              # Build and pipeline tools
prototypes/                         # Throwaway prototypes (isolated from src/)
production/                         # Sprint plans, milestones, release tracking
```

## 작동 방식

### 에이전트 조율

에이전트는 구조화된 위임 모델을 따릅니다:

1. **수직 위임** — 디렉터는 리드에게, 리드는 전문가에게 위임합니다
2. **수평 협의** — 동일 티어의 에이전트는 서로 협의할 수 있지만 도메인을 넘나드는 구속력 있는 결정은 내릴 수 없습니다
3. **갈등 해결** — 의견 불일치는 공통 상위 에이전트로 에스컬레이션됩니다(디자인은 `creative-director`, 기술은 `technical-director`)
4. **변경 전파** — 부서 간 변경 사항은 `producer`가 조율합니다
5. **도메인 경계** — 에이전트는 명시적인 위임 없이 자신의 도메인 밖 파일을 수정하지 않습니다

### 자율이 아닌 협업

이것은 자동조종(오토파일럿) 시스템이 **아닙니다**. 모든 에이전트는 엄격한 협업 프로토콜을 따릅니다:

1. **질문** — 에이전트는 해결책을 제안하기 전에 질문합니다
2. **옵션 제시** — 에이전트는 장단점을 포함한 2~4개의 옵션을 제시합니다
3. **사용자가 결정** — 항상 사용자가 최종 결정을 내립니다
4. **초안 작성** — 에이전트는 최종 확정 전에 작업물을 보여줍니다
5. **승인** — 사용자의 승인 없이는 아무것도 작성되지 않습니다

주도권은 항상 사용자에게 있습니다. 에이전트는 자율성이 아니라 구조와 전문성을 제공합니다.

### 자동화된 안전장치

**훅**은 모든 세션에서 자동으로 실행됩니다:

| 훅 | 트리거 | 동작 |
|------|---------|--------------|
| `validate-commit.sh` | PreToolUse (Bash) | 하드코딩된 값, TODO 형식, JSON 유효성, 디자인 문서 섹션을 검사 — 명령어가 `git commit`이 아니면 조기 종료 |
| `validate-push.sh` | PreToolUse (Bash) | 보호된 브랜치로의 푸시에 대해 경고 — 명령어가 `git push`가 아니면 조기 종료 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 네이밍 규칙과 JSON 구조를 검증 — 파일이 `assets/` 안에 없으면 조기 종료 |
| `session-start.sh` | Session open | 현재 브랜치와 최근 커밋을 보여줘 상황 파악을 돕습니다 |
| `detect-gaps.sh` | Session open | 신규 프로젝트를 감지(`/start` 제안)하고, 코드나 프로토타입이 있는데 디자인 문서가 없는 경우를 감지합니다 |
| `pre-compact.sh` | Before compaction | 세션 진행 메모를 보존합니다 |
| `post-compact.sh` | After compaction | `active.md`에서 세션 상태를 복원하도록 Claude에게 상기시킵니다 |
| `notify.sh` | Notification event | PowerShell을 통해 Windows 토스트 알림을 표시합니다 |
| `session-stop.sh` | Session close | `active.md`를 세션 로그에 보관하고 git 활동을 기록합니다 |
| `log-agent.sh` | Agent spawned | 감사 추적 시작 — 서브에이전트 호출을 기록합니다 |
| `log-agent-stop.sh` | Agent stops | 감사 추적 종료 — 서브에이전트 기록을 완료합니다 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | `.claude/skills/` 변경 후 `/skill-test` 실행을 권장합니다 |

> **참고**: `validate-commit.sh`, `validate-assets.sh`, `validate-skill-change.sh`는 모든 Bash/Write 툴 호출 시 실행되며, 명령어나 파일 경로가 관련이 없으면 즉시 종료(exit 0)됩니다. 이는 정상적인 훅 동작이며 성능 문제가 아닙니다.

`settings.json`의 **권한 규칙**은 안전한 작업(git status, 테스트 실행)은 자동 허용하고, 위험한 작업(강제 푸시, `rm -rf`, `.env` 파일 읽기)은 차단합니다.

### 경로 기반 규칙

코딩 표준은 파일 위치에 따라 자동으로 적용됩니다:

| 경로 | 적용 내용 |
|------|----------|
| `src/gameplay/**` | 데이터 기반 값, 델타 타임 사용, UI 참조 금지 |
| `src/core/**` | 핫 패스에서 할당 없음, 스레드 안전성, API 안정성 |
| `src/ai/**` | 성능 예산, 디버그 용이성, 데이터 기반 파라미터 |
| `src/networking/**` | 서버 권위(server-authoritative), 버전 관리된 메시지, 보안 |
| `src/ui/**` | 게임 상태 소유 금지, 로컬라이제이션 준비, 접근성 |
| `design/gdd/**` | 필수 8개 섹션, 공식 형식, 엣지 케이스 |
| `tests/**` | 테스트 네이밍, 커버리지 요구사항, 픽스처 패턴 |
| `prototypes/**` | 완화된 표준, README 필수, 가설 문서화 |

## 디자인 철학

이 템플릿은 전문적인 게임 개발 실무에 기반합니다:

- **MDA 프레임워크** — 게임 디자인을 위한 메커닉스, 다이내믹스, 미학 분석
- **자기결정이론(Self-Determination Theory)** — 플레이어 동기부여를 위한 자율성, 유능감, 관계성
- **플로우 상태 디자인** — 플레이어 몰입을 위한 도전-실력 균형
- **바틀 플레이어 유형(Bartle Player Types)** — 타깃 유저층 설정 및 검증
- **검증 주도 개발(Verification-Driven Development)** — 테스트를 먼저, 구현은 그다음

## 커스터마이징

이것은 고정된 프레임워크가 아니라 **템플릿**입니다. 모든 것은 커스터마이징하도록 만들어졌습니다:

- **에이전트 추가/제거** — 필요 없는 에이전트 파일을 삭제하고, 자신의 도메인을 위한 새 에이전트를 추가하세요
- **에이전트 프롬프트 편집** — 에이전트 동작을 조정하고 프로젝트별 지식을 추가하세요
- **스킬 수정** — 팀의 프로세스에 맞게 워크플로를 조정하세요
- **규칙 추가** — 프로젝트의 디렉터리 구조에 맞는 새로운 경로 기반 규칙을 만드세요
- **훅 조정** — 검증 엄격도를 조정하고 새로운 체크를 추가하세요
- **엔진 선택** — Godot, Unity, Unreal, Web 에이전트 세트 중 하나를 사용하거나(또는 사용하지 않아도) 됩니다
- **리뷰 강도 설정** — `full`(모든 디렉터 게이트), `lean`(단계 게이트만), `solo`(없음) 중 선택. `/start` 중에 설정하거나 `production/review-mode.txt`를 편집하세요. 어떤 스킬에서든 `--review solo`로 실행 단위 재정의가 가능합니다.

## 플랫폼 지원

### 지원 엔진

템플릿에는 네 가지 엔진 에이전트 세트가 포함되어 있습니다. `/setup-engine` 중에 하나를 선택하세요:

| 엔진 | 언어 | 에이전트 세트 |
|--------|----------|-----------|
| **Godot 4** | GDScript / C# | `godot-specialist` + 서브 전문가 4명 |
| **Unity** | C# | `unity-specialist` + 서브 전문가 4명 |
| **Unreal Engine 5** | C++ / Blueprint | `unreal-specialist` + 서브 전문가 4명 |
| **Web** | TypeScript | `web-specialist` + 서브 전문가 6명 |

Web 세트는 공유된 TypeScript/Vite/WebGPU 스택 위에서 **PixiJS**(2D), **Three.js**(3D),
또는 둘 다를 대상으로 합니다. `/setup-engine web`은 Godot 프로젝트에서 언어를 고르게
하는 것과 같은 방식으로 어떤 렌더러를 쓸지 묻습니다.

### 개발 플랫폼

주 개발 및 테스트는 Git Bash를 사용하는 **Windows 10**에서 이루어집니다. 모든 훅은 POSIX 호환 패턴(`grep -P`가 아닌 `grep -E`)을 사용하며 도구가 없을 때를 위한 대체 로직을 포함하므로 macOS와 Linux에서도 동작할 것입니다. `notify.sh` 훅은 Windows 토스트 알림을 위해 PowerShell을 사용하며 그 외 환경에서는 아무 동작도 하지 않습니다 — macOS/Linux의 데스크톱 알림은 아직 연결되어 있지 않습니다. 크로스플랫폼 테스트는 진행 중이며, 플랫폼별 문제가 발견되면 이슈를 등록해 주세요.

## 커뮤니티

- **Discussions** — 질문, 아이디어 공유, 완성한 결과물 소개를 위한 [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions)
- **Issues** — [버그 리포트 및 기능 요청](https://github.com/Donchitos/Claude-Code-Game-Studios/issues)

---

*Claude Code를 위해 제작되었습니다. 지속적으로 유지보수 및 확장되고 있으며 — [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions)를 통한 기여를 환영합니다.*

## 라이선스

MIT 라이선스입니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
