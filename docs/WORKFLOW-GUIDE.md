# Claude Code Game Studios -- 완전 워크플로 가이드

> **에이전트 아키텍처를 이용해 아이디어부터 출시까지 가는 방법.**
>
> 이 가이드는 49-agent 시스템, 73개 슬래시 명령어, 12개 자동화 훅을 사용하여
> 게임 개발의 모든 단계를 안내합니다. Claude Code가 설치되어 있고 프로젝트
> 루트에서 작업 중이라고 가정합니다.
>
> 파이프라인은 7개 단계로 구성됩니다. 각 단계에는 다음으로 진행하기 전에
> 통과해야 하는 공식 게이트(`/gate-check`)가 있습니다. 공식 단계 순서는
> `.claude/docs/workflow-catalog.yaml`에 정의되어 있으며 `/help`가 이를 읽습니다.

---

## 목차

1. [빠른 시작](#빠른-시작)
2. [단계 1: 컨셉](#단계-1-컨셉)
3. [단계 2: 시스템 설계](#단계-2-시스템-설계)
4. [단계 3: 기술 설정](#단계-3-기술-설정)
5. [단계 4: 프리프로덕션](#단계-4-프리프로덕션)
6. [단계 5: 프로덕션](#단계-5-프로덕션)
7. [단계 6: 폴리시](#단계-6-폴리시)
8. [단계 7: 릴리스](#단계-7-릴리스)
9. [교차 관심사](#교차-관심사)
10. [부록 A: 에이전트 빠른 참조](#부록-a-에이전트-빠른-참조)
11. [부록 B: 슬래시 명령어 빠른 참조](#부록-b-슬래시-명령어-빠른-참조)
12. [부록 C: 자주 쓰는 워크플로](#부록-c-자주-쓰는-워크플로)

---

## 빠른 시작

### 필요한 것

시작하기 전에 다음이 준비되어 있는지 확인하세요.

- **Claude Code** 설치 및 정상 작동
- **Git** (Windows는 Git Bash, Mac/Linux는 표준 터미널)
- **jq** (선택 사항이지만 권장 -- 없으면 훅이 `grep`으로 대체 동작)
- **Python 3** (선택 사항 -- 일부 훅이 JSON 검증에 사용)

### 1단계: 클론 및 열기

```bash
git clone <repo-url> my-game
cd my-game
```

### 2단계: /start 실행

첫 세션이라면:

```
/start
```

이 가이드형 온보딩은 현재 위치를 묻고 알맞은 단계로 안내합니다.

- **경로 A** -- 아직 아이디어 없음: `/brainstorm`으로 이동
- **경로 B** -- 막연한 아이디어: 시드를 가지고 `/brainstorm`으로 이동
- **경로 C** -- 명확한 컨셉: `/setup-engine`과 `/map-systems`로 이동
- **경로 D1** -- 기존 프로젝트, 산출물 적음: 일반 흐름
- **경로 D2** -- 기존 프로젝트, GDD/ADR 존재: `/project-stage-detect`를 실행한
  뒤 브라운필드 마이그레이션을 위해 `/adopt` 실행

### 3단계: 훅이 작동하는지 확인

새 Claude Code 세션을 시작하세요. `session-start.sh` 훅의 출력이 보여야 합니다.

```
=== Claude Code Game Studios -- Session Context ===
Branch: main
Recent commits:
  abc1234 Initial commit
===================================
```

이게 보이면 훅이 정상 작동하는 것입니다. 보이지 않으면 `.claude/settings.json`에서
운영체제에 맞는 훅 경로가 올바르게 설정되어 있는지 확인하세요.

### 4단계: 언제든 도움 요청하기

언제든지 다음을 실행하세요.

```
/help
```

이 명령어는 `production/stage.txt`에서 현재 단계를 읽고, 어떤 산출물이 존재하는지
확인한 뒤, 다음에 정확히 무엇을 해야 하는지 알려줍니다. REQUIRED(필수) 다음 단계와
OPTIONAL(선택) 기회를 구분해서 보여줍니다.

### 5단계: 디렉터리 구조 만들기

디렉터리는 필요할 때 생성됩니다. 시스템은 다음 레이아웃을 기대합니다.

```
src/                  # Game source code
  core/               # Engine/framework code
  gameplay/           # Gameplay systems
  ai/                 # AI systems
  networking/         # Multiplayer code
  ui/                 # UI code
  tools/              # Dev tools
assets/               # Game assets
  art/                # Sprites, models, textures
  audio/              # Music, SFX
  vfx/                # Particle effects
  shaders/            # Shader files
  data/               # JSON config/balance data
design/               # Design documents
  gdd/                # Game design documents
  narrative/          # Story, lore, dialogue
  levels/             # Level design documents
  balance/            # Balance spreadsheets and data
  ux/                 # UX specifications
docs/                 # Technical documentation
  architecture/       # Architecture Decision Records
  api/                # API documentation
  postmortems/        # Post-mortems
tests/                # Test suites
prototypes/           # Throwaway prototypes
production/           # Sprint plans, milestones, releases
  sprints/
  milestones/
  releases/
  epics/              # Epic and story files (from /create-epics + /create-stories)
  playtests/          # Playtest reports
  session-state/      # Ephemeral session state (gitignored)
  session-logs/       # Session audit trail (gitignored)
```

> **팁:** 첫날부터 이 모든 것이 필요하지는 않습니다. 필요한 단계에 도달했을 때
> 디렉터리를 만드세요. 중요한 것은 만들 때 이 구조를 따르는 것입니다.
> **규칙 시스템**이 파일 경로를 기준으로 표준을 적용하기 때문입니다.
> `src/gameplay/`의 코드는 gameplay 규칙을, `src/ai/`의 코드는 AI 규칙을 받는
> 식입니다.

---

## 단계 1: 컨셉

### 이 단계에서 일어나는 일

"아이디어 없음" 또는 "막연한 아이디어" 상태에서 필러(pillar)와 플레이어 여정이
정의된 구조화된 게임 컨셉 문서로 나아갑니다. 여기서 **무엇을** 만들지, **왜**
만드는지를 정합니다.

### 단계 1 파이프라인

```
/brainstorm  -->  game-concept.md  -->  /design-review  -->  /setup-engine
     |                                        |                    |
     v                                        v                    v
  10 concepts     Concept doc with       Validation          Engine pinned in
  MDA analysis    pillars, MDA,          of concept          technical-preferences.md
  Player motiv.   core loop, USP         document
                                                                   |
                                                                   v
                                                             /prototype
                                                       (concept prototype — 1-3 days)
                                                        PROCEED ↓     PIVOT → /brainstorm
                                                                   |
                                                                   v (PROCEED)
                                                             /map-systems
                                                                   |
                                                                   v
                                                            systems-index.md
                                                            (all systems, deps,
                                                             priority tiers)
```

### 1.1단계: /brainstorm으로 브레인스토밍

여기가 출발점입니다. 브레인스토밍 스킬을 실행하세요.

```
/brainstorm
```

또는 장르 힌트와 함께:

```
/brainstorm roguelike deckbuilder
```

**무슨 일이 일어나는가:** 브레인스토밍 스킬은 프로 스튜디오 기법을 활용한 협업형
6단계 아이디어 발상 과정을 안내합니다.

1. 관심사, 테마, 제약 조건을 묻습니다
2. MDA(Mechanics, Dynamics, Aesthetics) 분석과 함께 10개의 컨셉 시드를 생성합니다
3. 심층 분석을 위해 마음에 드는 2~3개를 고릅니다
4. 플레이어 동기 매핑과 타깃 오디언스 분석을 수행합니다
5. 최종 컨셉을 선택합니다
6. `design/gdd/game-concept.md`로 공식화합니다

컨셉 문서에는 다음이 포함됩니다.

- 엘리베이터 피치(한 문장)
- 코어 판타지(플레이어가 자신을 무엇으로 상상하는지)
- MDA 분석
- 타깃 오디언스(Bartle 유형, 인구통계)
- 코어 루프 다이어그램
- 고유 판매 제안(USP)
- 비교 대상 타이틀 및 차별점
- 게임 필러(3~5개의 협상 불가능한 디자인 가치)
- 안티필러(게임이 의도적으로 피하는 것들)

### 1.2단계: 컨셉 검토(선택, 권장)

```
/design-review design/gdd/game-concept.md
```

다음 단계로 진행하기 전에 구조와 완성도를 검증합니다.

### 1.3단계: 엔진 선택

```
/setup-engine
```

또는 특정 엔진을 지정하여:

```
/setup-engine godot 4.6
```

**/setup-engine이 하는 일:**

- 네이밍 컨벤션, 성능 예산, 엔진별 기본값으로 `.claude/docs/technical-preferences.md`를
  채웁니다
- 지식 격차(엔진 버전이 LLM 학습 데이터보다 최신인 경우)를 감지하고
  `docs/engine-reference/`를 함께 참조하라고 안내합니다
- `docs/engine-reference/`에 버전 고정 참조 문서를 만듭니다

**이게 왜 중요한가:** 엔진을 설정하면 시스템은 어떤 엔진 전문 에이전트를
사용할지 알게 됩니다. Godot을 선택하면 `godot-specialist`,
`godot-gdscript-specialist`, `godot-shader-specialist` 같은 에이전트가
전담 전문가가 됩니다.

### 1.4단계: 컨셉을 시스템으로 분해

개별 GDD를 작성하기 전에, 게임에 필요한 모든 시스템을 나열하세요.

```
/map-systems
```

이 명령어는 `design/gdd/systems-index.md`를 생성합니다 -- 다음을 수행하는
마스터 추적 문서입니다.

- 게임에 필요한 모든 시스템(전투, 이동, UI 등)을 나열
- 시스템 간 의존성을 매핑
- 우선순위 티어(MVP, Vertical Slice, Alpha, Full Vision)를 지정
- 설계 순서를 결정(Foundation > Core > Feature > Presentation > Polish)

이 단계는 단계 2로 넘어가기 전에 **필수**입니다. 155개 게임 포스트모템 조사에
따르면 시스템 나열을 건너뛰면 프로덕션 단계에서 비용이 5~10배 더 든다고
확인되었습니다.

### 단계 1 게이트

```
/gate-check concept
```

**통과 요건:**

- `technical-preferences.md`에 엔진이 설정되어 있음
- `design/gdd/game-concept.md`가 필러와 함께 존재함
- `design/gdd/systems-index.md`가 의존성 순서와 함께 존재함

**판정:** PASS / CONCERNS / FAIL. CONCERNS는 리스크를 인지한 상태로 통과
가능합니다. FAIL은 진행을 막습니다.

---

## 단계 2: 시스템 설계

### 이 단계에서 일어나는 일

게임이 어떻게 작동하는지 정의하는 모든 설계 문서를 작성합니다. 아직 코드는
작성하지 않습니다 -- 순수하게 설계만 합니다. 시스템 인덱스에서 식별된 각 시스템은
자체 GDD를 가지며, 섹션 단위로 작성되고 개별적으로 검토된 뒤, 모든 GDD가
일관성 여부를 상호 검증받습니다.

### 단계 2 파이프라인

```
/map-systems next  -->  /design-system  -->  /design-review
       |                     |                     |
       v                     v                     v
  Picks next system    Section-by-section     Validates 8
  from systems-index   GDD authoring          required sections
                       (incremental writes)   APPROVED/NEEDS REVISION
       |
       |  (repeat for each MVP system)
       v
/review-all-gdds
       |
       v
  Cross-GDD consistency + design theory review
  PASS / CONCERNS / FAIL
```

### 2.1단계: 시스템 GDD 작성

가이드형 워크플로를 사용해 의존성 순서대로 각 시스템을 설계하세요.

```
/map-systems next
```

가장 우선순위가 높은, 아직 설계되지 않은 시스템을 선택해 `/design-system`으로
넘겨주며, 이 명령어는 GDD를 섹션 단위로 작성하도록 안내합니다.

특정 시스템을 직접 설계할 수도 있습니다.

```
/design-system combat-system
```

**/design-system이 하는 일:**

1. 게임 컨셉, 시스템 인덱스, 관련된 상위/하위 GDD를 읽습니다
2. 기술 타당성 사전 점검(도메인 매핑 + 타당성 브리프)을 수행합니다
3. 8개의 필수 GDD 섹션을 하나씩 순서대로 안내합니다
4. 각 섹션은 다음 순서를 따릅니다: Context > Questions > Options > Decision > Draft > Approval > Write
5. 각 섹션은 승인 즉시 파일로 기록됩니다(크래시에도 안전)
6. 기존 승인된 GDD와의 충돌을 표시합니다
7. 카테고리별로 전문 에이전트에게 라우팅합니다(수식은 systems-designer,
   경제는 economy-designer, 스토리 시스템은 narrative-director)

**8개의 필수 GDD 섹션:**

| # | 섹션 | 여기에 들어갈 내용 |
|---|---------|---------------|
| 1 | **Overview** | 시스템에 대한 한 문단 요약 |
| 2 | **Player Fantasy** | 이 시스템을 사용할 때 플레이어가 상상하거나 느끼는 것 |
| 3 | **Detailed Rules** | 모호함이 없는 메커니즘 규칙 |
| 4 | **Formulas** | 변수 정의와 범위를 포함한 모든 계산식 |
| 5 | **Edge Cases** | 이상한 상황에서 무슨 일이 일어나는가? 명시적으로 해결. |
| 6 | **Dependencies** | 이 시스템이 연결되는 다른 시스템(양방향) |
| 7 | **Tuning Knobs** | 디자이너가 안전하게 바꿀 수 있는 값과 안전 범위 |
| 8 | **Acceptance Criteria** | 이 시스템이 제대로 작동하는지 어떻게 테스트하는가? 구체적이고 측정 가능해야 함. |

여기에 더해 **Game Feel** 섹션도 포함됩니다: 필 레퍼런스, 입력 반응성(ms/프레임),
애니메이션 필 목표(startup/active/recovery), 임팩트 모먼트, 웨이트 프로필.

### 2.2단계: 각 GDD 검토

다음 시스템을 시작하기 전에 현재 시스템을 검증하세요.

```
/design-review design/gdd/combat-system.md
```

8개 섹션 모두의 완성도, 수식의 명확성, 엣지 케이스 해결 여부, 양방향 의존성,
테스트 가능한 수용 기준을 확인합니다.

**판정:** APPROVED / NEEDS REVISION / MAJOR REVISION. APPROVED된 GDD만
다음 단계로 진행해야 합니다.

### 2.3단계: 전체 GDD 없이 소규모 변경하기

전체 GDD를 작성할 필요가 없는 튜닝 변경, 소규모 추가, 소소한 조정의 경우:

```
/quick-design "add 10% damage bonus for flanking attacks"
```

이 명령어는 전체 8섹션 GDD 대신 `design/quick-specs/`에 경량 스펙을 생성합니다.
튜닝, 수치 변경, 소규모 추가에 사용하세요.

### 2.4단계: 크로스 GDD 일관성 검토

모든 MVP 시스템 GDD가 개별적으로 승인된 후:

```
/review-all-gdds
```

이 명령어는 모든 GDD를 동시에 읽고 두 가지 분석 단계를 수행합니다.

**1단계 -- 크로스 GDD 일관성:**
- 의존성 양방향성(A가 B를 참조하면, B도 A를 참조하는가?)
- 시스템 간 규칙 모순
- 이름이 바뀌거나 제거된 시스템에 대한 오래된 참조
- 소유권 충돌(두 시스템이 같은 책임을 주장)
- 수식 범위 호환성(시스템 A의 출력이 시스템 B의 입력에 맞는가?)
- 수용 기준 교차 검증

**2단계 -- 디자인 이론(게임 디자인 전체론):**
- 경쟁하는 진행 루프(두 시스템이 같은 보상 공간을 두고 경쟁하는가?)
- 인지 부하(동시에 활성화된 시스템이 4개 이상인가?)
- 지배 전략(다른 모든 접근을 무의미하게 만드는 한 가지 방법)
- 경제 루프 분석(소스와 싱크가 균형을 이루는가?)
- 시스템 간 난이도 곡선의 일관성
- 필러 정합성 및 안티필러 위반
- 플레이어 판타지의 일관성

**출력:** `design/gdd/gdd-cross-review-[date].md`에 판정과 함께 기록됩니다.

### 2.5단계: 내러티브 설계(해당하는 경우)

게임에 스토리, 세계관, 대사가 있다면 이때 만듭니다.

1. **세계관 구축** -- `world-builder`를 사용해 세력, 역사, 지리, 세계 규칙을 정의합니다
2. **스토리 구조** -- `narrative-director`를 사용해 스토리 아크, 캐릭터 아크,
   내러티브 비트를 설계합니다
3. **캐릭터 시트** -- `narrative-character-sheet.md` 템플릿을 사용합니다

### 단계 2 게이트

```
/gate-check systems-design
```

**통과 요건:**

- `systems-index.md`의 모든 MVP 시스템이 `Status: Approved` 상태임
- 각 MVP 시스템에 검토를 마친 GDD가 있음
- 크로스 GDD 검토 보고서가 존재(`design/gdd/gdd-cross-review-*.md`)하며
  판정이 PASS 또는 CONCERNS임(FAIL이 아님)

---

## 단계 3: 기술 설정

### 이 단계에서 일어나는 일

핵심 기술 결정을 내리고, 이를 아키텍처 결정 기록(ADR)으로 문서화하고, 검토를
통해 검증한 뒤, 프로그래머에게 명료하고 실행 가능한 규칙을 제공하는 컨트롤
매니페스트를 만듭니다. 또한 UX 기반도 이 단계에서 마련합니다.

### 단계 3 파이프라인

```
/create-architecture  -->  /architecture-decision (x N)  -->  /architecture-review
        |                          |                                   |
        v                          v                                   v
  Master architecture       Per-decision ADRs              Validates completeness,
  document covering         in docs/architecture/          dependency ordering,
  all systems               adr-*.md                       engine compatibility
                                                                      |
                                                                      v
                                                         /create-control-manifest
                                                                      |
                                                                      v
                                                         Flat programmer rules
                                                         docs/architecture/
                                                         control-manifest.md
        Also in this phase:
        -------------------
        /ux-design  -->  /ux-review
        Accessibility requirements doc
        Interaction pattern library
```

### 3.1단계: 마스터 아키텍처 문서

```
/create-architecture
```

시스템 경계, 데이터 흐름, 통합 지점을 다루는 전체 아키텍처 문서를
`docs/architecture/architecture.md`에 생성합니다.

### 3.2단계: 아키텍처 결정 기록(ADR)

중요한 기술 결정마다:

```
/architecture-decision "State Machine vs Behavior Tree for NPC AI"
```

**무슨 일이 일어나는가:** 이 스킬은 다음 내용을 포함한 ADR을 작성하도록
안내합니다.
- 맥락과 의사결정 동인
- 장단점과 엔진 호환성을 포함한 모든 옵션
- 근거와 함께 선택된 옵션
- 결과(긍정적, 부정적, 리스크)
- 의존성(Depends On, Enables, Blocks, Ordering Note)
- 다루는 GDD 요구사항(TR-ID로 연결)

ADR은 다음 생애주기를 거칩니다: Proposed > Accepted > Superseded/Deprecated.

게이트 체크 전에 **최소 3개의 Foundation 계층 ADR**이 필요합니다.

**기존 ADR을 소급 보완하기:** 브라운필드 프로젝트에서 이미 ADR을 보유하고
있다면:

```
/architecture-decision retrofit docs/architecture/adr-005.md
```

이 명령어는 어떤 템플릿 섹션이 빠졌는지 감지해 그 부분만 추가하고, 기존
내용은 절대 덮어쓰지 않습니다.

### 3.3단계: 아키텍처 검토

```
/architecture-review
```

모든 ADR을 함께 검증합니다.
- ADR 의존성의 위상 정렬(순환 참조 감지)
- 엔진 호환성 검증
- GDD 수정 플래그(ADR 선택에 따라 업데이트가 필요한 GDD 섹션 표시)
- TR-ID 레지스트리 유지 관리(`docs/architecture/tr-registry.yaml`)

### 3.4단계: 컨트롤 매니페스트

```
/create-control-manifest
```

모든 Accepted 상태의 ADR을 받아 프로그래머용 규칙표를 생성합니다.

```
docs/architecture/control-manifest.md
```

여기에는 코드 레이어별로 정리된 필수 패턴(Required), 금지 패턴(Forbidden),
가드레일(Guardrails)이 포함됩니다. 이후 생성되는 스토리는 매니페스트 버전
날짜를 함께 기록해 오래된 상태를 감지할 수 있게 합니다.

### 3.5단계: 접근성 요구사항

템플릿을 사용해 `design/accessibility-requirements.md`를 만드세요. 티어(Basic /
Standard / Comprehensive / Exemplary) 하나를 확정하고 4축 기능 매트릭스(시각,
운동, 인지, 청각)를 채우세요.

이 문서는 단계 4에서 작성되는 UX 스펙이 이 티어를 참조하기 때문에 단계 3에서
필요합니다 — 이것은 UX 산출물이 아니라 설계 전제조건입니다.

### 단계 3 게이트

```
/gate-check technical-setup
```

**통과 요건:**

- `docs/architecture/architecture.md`가 존재함
- 최소 3개의 ADR이 존재하며 Accepted 상태임
- 아키텍처 검토 보고서가 존재함
- `docs/architecture/control-manifest.md`가 존재함
- `design/accessibility-requirements.md`가 존재함

---

## 단계 4: 프리프로덕션

### 이 단계에서 일어나는 일

핵심 화면에 대한 UX 스펙을 만들고, 위험한 메커닉을 프로토타이핑하고, 설계
문서를 구현 가능한 스토리로 변환하고, 첫 스프린트를 계획하고, 코어 루프가
재미있음을 증명하는 Vertical Slice를 빌드합니다.

### 단계 4 파이프라인

```
/ux-design  -->  /vertical-slice  -->  /create-epics  -->  /create-stories  -->  /sprint-plan
    |                   |                   |                   |                       |
    v                   v                   v                   v                       v
  UX specs       Production-quality   Epic files in       Story files in          First sprint with
  design/ux/     end-to-end build     production/         production/             prioritized stories
                 in prototypes/       epics/*/EPIC.md     epics/*/story-*.md      production/sprints/
                 PROCEED/PIVOT/KILL   (one per module)    (one per behaviour)     sprint-*.md
    |                                                          |
    v                                                          v
 /ux-review                                             /story-readiness
 (validates specs                                       (validates each story
  before epics)                                          before pickup)
                                                               |
                                                               v
                                                           /dev-story
                                                         (implements the story,
                                                          routes to right agent)
```

### 4.1단계: 핵심 화면의 UX 스펙

에픽을 작성하기 전에 UX 스펙을 만들어, 스토리 작성자가 어떤 화면이 존재하고
어떤 플레이어 인터랙션을 지원해야 하는지 알 수 있도록 하세요.

**UX 스펙:**

```
/ux-design main-menu
/ux-design core-gameplay-hud
```

세 가지 모드: 화면/플로우, HUD, 인터랙션 패턴. 출력은 `design/ux/`에
저장됩니다. 각 스펙에는 플레이어 니즈, 레이아웃 존, 상태, 인터랙션 맵, 데이터
요구사항, 발생 이벤트, 접근성, 로컬라이제이션이 포함됩니다.

단계 3에서 작성한 `accessibility-requirements.md`와 `technical-preferences.md`의
입력 방식 설정을 읽어 접근성 및 입력 커버리지 점검을 자동으로 진행합니다 —
화면마다 다시 지정할 필요가 없습니다.

> **팁:** `/design-system`은 UI 요구사항이 있는 모든 시스템에 대해
> 📌 UX Flag를 표시합니다. 어떤 화면에 스펙이 필요한지 체크리스트로
> 활용하세요.

**인터랙션 패턴 라이브러리:**

```
/ux-design interaction-patterns
```

`design/ux/interaction-patterns.md`를 만드세요 — 16개의 표준 컨트롤과
게임 고유 패턴(인벤토리 슬롯, 어빌리티 아이콘, HUD 바, 대화 상자 등)을
애니메이션 및 사운드 표준과 함께 정의합니다.

**UX 검토:**

```
/ux-review all
```

UX 스펙이 GDD와 정합하는지, 접근성 티어를 준수하는지 검증합니다.
APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 판정을 내립니다.

### 4.2단계: Vertical Slice 빌드하기

Vertical Slice는 전체 Production으로 진입하기 전에 전체 게임 루프를
엔드투엔드로 만들 수 있음을 증명하는 프로덕션 품질의 증거입니다.

```
/vertical-slice
```

**무엇을 증명하는가:** 아무것도 모른 채 시작한 플레이어가, 개발자의 안내
없이도 몇 분 안에 코어 판타지를 경험하는가?

**무엇을 만드는가:** 적어도 하나의 완전한 [시작 → 도전 → 해결] 사이클을
다루는, 거의 프로덕션 수준의 플레이 가능한 빌드입니다. 실제 아키텍처
레이어와 실제 네이밍 컨벤션을 사용하고 하드코딩된 값이 없어야 하지만 —
최종 아트나 오디오는 아닙니다. 컨셉 프로토타입처럼 버리는 물건이 아니라
프로덕션 파이프라인이 실현 가능함을 보여주는 것입니다.

**컨셉 프로토타이핑에 관한 참고:** 단계 1(컨셉)에서 `/prototype`을
실행했다면 이미 코어 아이디어가 재미있다는 것을 검증한 상태입니다.
이제 Vertical Slice는 이를 제대로 만들 수 있는지를 검증합니다. 둘은
서로 다른 질문에 답합니다. 컨셉 프로토타입을 건너뛰었다면, 전체 슬라이스에
투자하기 전에 지금 먼저 하나 실행하는 것이 합리적입니다.

**판정:** Vertical Slice는 PROCEED / PIVOT / KILL 판정을 내립니다.
- **PROCEED** → 4.3단계(에픽과 스토리)로 이동
- **PIVOT** → `/design-system [mechanic]`으로 영향받은 GDD를 수정한 뒤
  `/vertical-slice`를 다시 실행
- **KILL** → 배운 내용을 가지고 `/brainstorm`으로 돌아감

### 4.3단계: 설계 산출물로부터 에픽과 스토리 만들기

```
/create-epics layer: foundation
/create-stories [epic-slug]   # repeat for each epic
/create-epics layer: core
/create-stories [epic-slug]   # repeat for each core epic
```

`/create-epics`는 GDD, ADR, 아키텍처를 읽어 에픽 범위를 정의합니다 —
아키텍처 모듈당 하나의 에픽입니다. 그런 다음 `/create-stories`가 각 에픽을
`production/epics/[slug]/` 안의 구현 가능한 스토리 파일로 나눕니다. 각
스토리에는 다음이 포함됩니다.
- GDD 요구사항 참조(인용 텍스트가 아닌 TR-ID -- 최신 상태 유지)
- ADR 참조(Accepted ADR에서만; Proposed ADR은 `Status: Blocked`를 유발)
- 컨트롤 매니페스트 버전 날짜(오래된 상태 감지용)
- 엔진별 구현 노트
- GDD에서 가져온 수용 기준

스토리가 만들어지면 `/dev-story [story-path]`를 실행해 하나를 구현하세요 —
알맞은 프로그래머 에이전트로 자동 라우팅됩니다.

### 4.4단계: 착수 전 스토리 검증

```
/story-readiness production/epics/combat/story-combat-damage-calc.md
```

확인 항목: 설계 완성도, 아키텍처 커버리지, 범위 명확성, 완료 정의(Definition
of Done). 판정: READY / NEEDS WORK / BLOCKED.

### 4.5단계: 공수 산정

```
/estimate production/epics/combat/story-combat-damage-calc.md
```

리스크 평가와 함께 공수 산정을 제공합니다.

### 4.6단계: 첫 스프린트 계획

```
/sprint-plan new
```

**무슨 일이 일어나는가:** `producer` 에이전트가 스프린트 계획을 함께
진행합니다.
- 스프린트 목표와 가용 시간을 묻습니다
- 목표를 Must Have / Should Have / Nice to Have 작업으로 나눕니다
- 리스크와 블로커를 식별합니다
- `production/sprints/sprint-01.md`를 생성합니다
- `production/sprint-status.yaml`(기계가 읽을 수 있는 스토리 추적 파일)을
  채웁니다

### 4.7단계: Vertical Slice(하드 게이트)

Production으로 진행하기 전에 Vertical Slice를 빌드하고 플레이테스트해야
합니다.

- 처음부터 끝까지 플레이 가능한, 완전한 엔드투엔드 코어 루프 하나
- 대표성 있는 품질(모든 것이 플레이스홀더가 아님)
- 최소 3회 세션에서 안내 없이 플레이됨
- 플레이테스트 보고서 작성(`/playtest-report`)

이것은 **하드 게이트**입니다 -- 사람이 안내 없이 빌드를 플레이하지 않았다면
`/gate-check`가 자동으로 FAIL 처리합니다.

### 단계 4 게이트

```
/gate-check pre-production
```

**통과 요건:**

- `design/ux/`에 검토를 마친 UX 스펙이 최소 1개 존재
- UX 검토 완료(APPROVED 또는 문서화된 리스크를 동반한 NEEDS REVISION)
- README를 갖춘 프로토타입이 최소 1개 존재
- `production/epics/[epic-slug]/`에 스토리 파일이 존재
- 스프린트 계획이 최소 1개 존재
- 플레이테스트 보고서가 최소 1개 존재(Vertical Slice가 3회 이상 세션에서
  플레이됨)

---

## 단계 5: 프로덕션

### 이 단계에서 일어나는 일

이것이 핵심 프로덕션 루프입니다. 스프린트(일반적으로 1~2주) 단위로 작업하며,
스토리별로 기능을 구현하고, 진행 상황을 추적하고, 구조화된 완료 검토를 통해
스토리를 마무리합니다. 게임이 콘텐츠 완성 상태에 도달할 때까지 이 단계를
반복합니다.

### 단계 5 파이프라인(스프린트별)

```
/sprint-plan new  -->  /story-readiness  -->  implement  -->  /story-done
       |                     |                    |                |
       v                     v                    v                v
  Sprint created       Story validated      Code written     8-phase review:
  sprint-status.yaml   READY verdict        Tests pass       verify criteria,
  populated                                                  check deviations,
                                                             update story status
       |
       |  (repeat per story until sprint complete)
       v
  /sprint-status  (quick 30-line snapshot anytime)
  /scope-check    (if scope is growing)
  /retrospective  (at sprint end)
```

### 5.1단계: 스토리 생애주기

프로덕션 단계는 **스토리 생애주기**를 중심으로 돌아갑니다.

```
/story-readiness  -->  implement  -->  /story-done  -->  next story
```

**1. 스토리 준비도(Readiness):** 스토리를 착수하기 전에 검증하세요.

```
/story-readiness production/epics/combat/story-combat-damage-calc.md
```

이 명령어는 설계 완성도, 아키텍처 커버리지, ADR 상태(ADR이 아직 Proposed면
차단), 컨트롤 매니페스트 버전(오래된 경우 경고), 범위 명확성을 확인합니다.
판정: READY / NEEDS WORK / BLOCKED.

**2. 구현:** 적절한 에이전트와 함께 작업하세요.

- 게임플레이 시스템은 `gameplay-programmer`
- 핵심 엔진 작업은 `engine-programmer`
- AI 동작은 `ai-programmer`
- 멀티플레이어는 `network-programmer`
- UI 코드는 `ui-programmer`
- 개발 도구는 `tools-programmer`

모든 에이전트는 협업 프로토콜을 따릅니다: 설계 문서를 읽고, 명확화 질문을
하고, 아키텍처 옵션을 제시하고, 승인을 받은 뒤 구현합니다.

**3. 스토리 완료:** 스토리가 끝나면:

```
/story-done production/epics/combat/story-combat-damage-calc.md
```

이 명령어는 8단계 완료 검토를 실행합니다.
1. 스토리 파일을 찾아 읽습니다
2. 참조된 GDD, ADR, 컨트롤 매니페스트를 불러옵니다
3. 수용 기준을 검증합니다(자동 확인 가능, 수동, 지연)
4. GDD/ADR 이탈 여부를 확인합니다(BLOCKING / ADVISORY / OUT OF SCOPE)
5. 코드 리뷰를 요청합니다
6. 완료 보고서를 생성합니다(COMPLETE / COMPLETE WITH NOTES / BLOCKED)
7. 스토리를 `Status: Complete`로 업데이트하고 완료 노트를 남깁니다
8. 다음 준비된 스토리를 표시합니다

검토 중 발견된 기술 부채는 `docs/tech-debt-register.md`에 기록됩니다.

### 5.2단계: 스프린트 추적

언제든지 진행 상황을 확인하세요.

```
/sprint-status
```

`production/sprint-status.yaml`을 읽는 빠른 30줄짜리 스냅샷입니다.

범위가 커지고 있다면:

```
/scope-check production/sprints/sprint-03.md
```

이 명령어는 현재 범위를 원래 계획과 비교해 범위 증가를 표시하고, 삭감을
권장합니다.

### 5.3단계: 콘텐츠 추적

```
/content-audit
```

GDD에 명시된 콘텐츠와 실제 구현된 콘텐츠를 비교합니다. 콘텐츠 격차를
조기에 포착합니다.

### 5.4단계: 설계 변경 전파

스토리가 만들어진 이후 GDD가 변경되면:

```
/propagate-design-change design/gdd/combat-system.md
```

GDD를 git-diff하여 영향받는 ADR을 찾고, 영향 보고서를 생성하고,
Superseded/업데이트/유지 결정을 안내합니다.

### 5.5단계: 다중 시스템 기능(팀 오케스트레이션)

여러 도메인에 걸친 기능은 팀 스킬을 사용하세요.

```
/team-combat "healing ability with HoT and cleanse"
/team-narrative "Act 2 story content"
/team-ui "inventory screen redesign"
/team-level "forest dungeon level"
/team-audio "combat audio pass"
```

각 팀 스킬은 6단계 협업 워크플로를 조율합니다.
1. **설계** -- game-designer가 질문하고 옵션을 제시
2. **아키텍처** -- lead-programmer가 코드 구조를 제안
3. **병렬 구현** -- 전문가들이 동시에 작업
4. **통합** -- gameplay-programmer가 모든 것을 연결
5. **검증** -- qa-tester가 수용 기준에 따라 테스트
6. **보고** -- 코디네이터가 상태를 요약

오케스트레이션은 자동화되어 있지만 **의사결정 지점은 여전히 사용자의
몫입니다**.

### 5.6단계: 스프린트 검토와 다음 스프린트

스프린트가 끝날 때:

```
/retrospective
```

계획 대비 완료, 벨로시티, 블로커, 실행 가능한 개선점을 분석합니다.

그런 다음 다음 스프린트를 계획하세요.

```
/sprint-plan new
```

### 5.7단계: 마일스톤 검토

마일스톤 체크포인트에서:

```
/milestone-review "alpha"
```

기능 완성도, 품질 지표, 리스크 평가, go/no-go 권고를 생성합니다.

### 단계 5 게이트

```
/gate-check production
```

**통과 요건:**

- 모든 MVP 스토리가 완료됨
- 신규 플레이어, 미드게임, 난이도 곡선을 다루는 3회의 플레이테스트
- 재미 가설이 검증됨
- 플레이테스트 데이터에 혼란 루프가 없음

---

## 단계 6: 폴리시

### 이 단계에서 일어나는 일

게임이 기능적으로 완성되었습니다. 이제 좋게 만들 차례입니다. 이 단계는 성능,
밸런스, 접근성, 오디오, 비주얼 폴리시, 플레이테스트에 집중합니다.

### 단계 6 파이프라인

```
/perf-profile  -->  /balance-check  -->  /asset-audit  -->  /playtest-report (x3)
       |                  |                    |                    |
       v                  v                    v                    v
  Profile CPU/GPU    Analyze formulas     Verify naming,      Cover: new player,
  memory, optimize   and data for         formats, sizes      mid-game, difficulty
  bottlenecks        broken progressions                      curve

  /tech-debt  -->  /team-polish
       |                |
       v                v
  Track and        Coordinated pass:
  prioritize       performance + art +
  debt items       audio + UX + QA
```

### 6.1단계: 성능 프로파일링

```
/perf-profile
```

구조화된 성능 프로파일링을 안내합니다.
- 목표 설정(FPS, 메모리, 플랫폼)
- 영향도 순으로 병목 식별
- 코드 위치와 예상 효과를 포함한 실행 가능한 최적화 작업 생성

### 6.2단계: 밸런스 분석

```
/balance-check assets/data/combat_damage.json
```

밸런스 데이터를 분석해 통계적 이상치, 깨진 진행 곡선, 퇴화 전략, 경제
불균형을 찾아냅니다.

### 6.3단계: 애셋 감사

```
/asset-audit
```

모든 애셋에 걸쳐 네이밍 컨벤션, 파일 형식 표준, 크기 예산을 검증합니다.

### 6.4단계: 플레이테스트(필수: 3회 세션)

```
/playtest-report
```

구조화된 플레이테스트 보고서를 생성합니다. 다음을 다루는 3회 세션이
필요합니다.
- 신규 플레이어 경험
- 미드게임 시스템
- 난이도 곡선

### 6.5단계: 기술 부채 평가

```
/tech-debt
```

TODO/FIXME/HACK 주석, 코드 중복, 지나치게 복잡한 함수, 누락된 테스트,
오래된 의존성을 스캔합니다. 각 항목은 분류되고 우선순위가 매겨집니다.

### 6.6단계: 조율된 폴리시 패스

```
/team-polish "combat system"
```

4명의 전문가를 병렬로 조율합니다.
1. 성능 최적화(performance-analyst)
2. 비주얼 폴리시(technical-artist)
3. 오디오 폴리시(sound-designer)
4. 필/주스(gameplay-programmer + technical-artist)

우선순위는 사용자가 정하고, 팀은 각 단계마다 승인을 받으며 실행합니다.

### 6.7단계: 로컬라이제이션과 접근성

```
/localize src/
```

하드코딩된 문자열, 번역을 깨뜨리는 문자열 연결, 확장을 고려하지 않은 텍스트,
누락된 로케일 파일을 스캔합니다.

접근성은 단계 3의 접근성 요구사항 문서에서 확정한 티어를 기준으로
감사됩니다.

### 단계 6 게이트

```
/gate-check polish
```

**통과 요건:**

- 최소 3개의 플레이테스트 보고서가 존재
- 조율된 폴리시 패스가 완료됨(`/team-polish`)
- 진행을 막는 성능 이슈가 없음
- 접근성 티어 요구사항이 충족됨

---

## 단계 7: 릴리스

### 이 단계에서 일어나는 일

게임이 다듬어졌고, 테스트를 마쳤고, 준비되었습니다. 이제 출시할 차례입니다.

### 단계 7 파이프라인

```
/release-checklist  -->  /launch-checklist  -->  /team-release
        |                       |                      |
        v                       v                      v
  Pre-release             Full cross-department    Coordinate:
  validation across       validation (Go/No-Go     build, QA sign-off,
  code, content,          per department)           deployment, launch
  store, legal
                    Also: /changelog, /patch-notes, /hotfix
```

### 7.1단계: 릴리스 체크리스트

```
/release-checklist v1.0.0
```

다음을 다루는 포괄적인 출시 전 체크리스트를 생성합니다.
- 빌드 검증(모든 플랫폼이 컴파일되고 실행됨)
- 인증 요구사항(플랫폼별)
- 스토어 메타데이터(설명, 스크린샷, 트레일러)
- 법적 준수(EULA, 개인정보처리방침, 등급)
- 세이브 게임 호환성
- 분석(애널리틱스) 검증

### 7.2단계: 출시 준비도(전체 검증)

```
/launch-checklist
```

부서 간 전체 검증입니다.

| 부서 | 확인 항목 |
|-----------|---------------|
| **엔지니어링** | 빌드 안정성, 크래시율, 메모리 누수, 로딩 시간 |
| **디자인** | 기능 완성도, 튜토리얼 흐름, 난이도 곡선 |
| **아트** | 애셋 품질, 누락된 텍스처, LOD 레벨 |
| **오디오** | 누락된 사운드, 믹싱 레벨, 공간 음향 |
| **QA** | 심각도별 오픈 버그 수, 회귀 테스트 통과율 |
| **내러티브** | 대사 완성도, 세계관 일관성, 오탈자 |
| **로컬라이제이션** | 모든 문자열 번역 완료, 잘림 없음, 로케일 테스트 |
| **접근성** | 준수 체크리스트, 보조 기능 테스트 |
| **스토어** | 메타데이터 완료, 스크린샷 승인, 가격 설정 |
| **마케팅** | 프레스킷 준비, 출시 트레일러, 소셜 미디어 예약 |
| **커뮤니티** | 패치 노트 초안, FAQ 준비, 지원 채널 준비 |
| **인프라** | 서버 스케일링, CDN 구성, 모니터링 활성화 |
| **법무** | EULA 확정, 개인정보처리방침, COPPA/GDPR 준수 |

각 항목은 **Go / No-Go** 상태를 받습니다. 출시하려면 모두 Go여야 합니다.

### 7.3단계: 플레이어 대상 콘텐츠 생성

```
/patch-notes v1.0.0
```

git 히스토리와 스프린트 데이터로부터 플레이어 친화적인 패치 노트를
생성합니다. 개발자 언어를 플레이어 언어로 번역합니다.

```
/changelog v1.0.0
```

내부용 체인지로그(더 기술적이며 팀을 위한 것)를 생성합니다.

### 7.4단계: 릴리스 조율

```
/team-release
```

release-manager, QA, DevOps를 다음 순서로 조율합니다.
1. 출시 전 검증
2. 빌드 관리
3. 최종 QA 승인
4. 배포 준비
5. Go/No-Go 결정

### 7.5단계: 출시

`validate-push` 훅은 `main`이나 `develop`에 푸시할 때 경고를 표시합니다.
이는 의도된 것입니다 -- 릴리스 푸시는 신중해야 합니다.

```bash
git tag v1.0.0
git push origin main --tags
```

### 7.6단계: 출시 후

프로덕션의 치명적인 버그를 위한 **핫픽스 워크플로**:

```
/hotfix "Players losing save data when inventory exceeds 99 items"
```

전체 감사 추적과 함께 일반 스프린트 프로세스를 우회합니다.
1. 핫픽스 브랜치를 생성합니다
2. 수정 사항을 구현합니다
3. 개발 브랜치로의 백포트를 보장합니다
4. 인시던트를 문서화합니다

출시가 안정된 후 **포스트모템**:

```
Ask Claude to create a post-mortem using the template at
.claude/docs/templates/post-mortem.md
```

---

## 교차 관심사

다음 주제들은 모든 단계에 걸쳐 적용됩니다.

### 디렉터 리뷰 모드

디렉터 게이트는 워크플로의 주요 지점에서 작업을 검토하는 전문 에이전트입니다.
기본적으로 모든 체크포인트에서 실행됩니다. 검토를 얼마나 받을지는 조절할 수
있습니다.

**`/start` 진행 중 검토 강도를 한 번 설정하세요.** `production/review-mode.txt`에
저장됩니다.

| 모드 | 실행되는 것 | 적합한 대상 |
|------|-----------|----------|
| `full` | 모든 단계에서 모든 디렉터 게이트 실행 | 새 프로젝트, 시스템 학습 중 |
| `lean` | 단계 전환 시(`/gate-check`)에만 디렉터 실행 | 숙련된 개발자 |
| `solo` | 디렉터 검토 없음 | 게임 잼, 프로토타입, 최대 속도 |

전역 설정을 바꾸지 않고 **단일 실행에 대해서만 재정의**하려면:

```
/brainstorm space horror --review full
/architecture-decision --review solo
```

`--review` 플래그는 게이트를 사용하는 모든 스킬에서 작동합니다. 전역 모드는
`production/review-mode.txt`를 직접 편집하거나 `/start`를 다시 실행해 언제든
바꿀 수 있습니다.

전체 게이트 정의와 확인 패턴: `.claude/docs/director-gates.md`

---

### 협업 프로토콜

이 시스템은 **사용자 주도 협업형**이며 자율 실행형이 아닙니다.

**패턴:** Question > Options > Decision > Draft > Approval

모든 에이전트 상호작용은 다음 패턴을 따릅니다.
1. 에이전트가 명확화 질문을 합니다
2. 에이전트가 트레이드오프와 근거를 담은 2~4개의 옵션을 제시합니다
3. 사용자가 결정합니다
4. 에이전트가 사용자의 결정을 바탕으로 초안을 작성합니다
5. 사용자가 검토하고 다듬습니다
6. 에이전트가 작성 전에 "[filepath]에 이 내용을 써도 될까요?"라고 묻습니다

전체 프로토콜과 예시는 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`를 참고하세요.

### AskUserQuestion 도구

에이전트는 구조화된 옵션 제시를 위해 `AskUserQuestion` 도구를 사용합니다.
패턴은 설명 후 캡처입니다: 대화 텍스트에서 먼저 전체 분석을 제시한 뒤,
결정을 위한 깔끔한 UI 선택지를 제공합니다. 설계 선택, 아키텍처 결정, 전략적
질문에 사용하세요. 개방형 탐색 질문이나 단순한 예/아니오 확인에는 사용하지
마세요.

### 에이전트 조율(3계층 위계)

```
Tier 1 (Directors):    creative-director, technical-director, producer
                                          |
Tier 2 (Leads):        game-designer, lead-programmer, art-director,
                       audio-director, narrative-director, qa-lead,
                       release-manager, localization-lead
                                          |
Tier 3 (Specialists):  gameplay-programmer, engine-programmer,
                       ai-programmer, network-programmer, ui-programmer,
                       tools-programmer, systems-designer, level-designer,
                       economy-designer, world-builder, writer,
                       technical-artist, sound-designer, ux-designer,
                       qa-tester, performance-analyst, devops-engineer,
                       analytics-engineer, accessibility-specialist,
                       live-ops-designer, prototyper, security-engineer,
                       community-manager, godot-specialist,
                       godot-gdscript-specialist, godot-shader-specialist,
                       godot-csharp-specialist, godot-gdextension-specialist,
                       unity-specialist, unity-dots-specialist,
                       unity-shader-specialist, unity-addressables-specialist,
                       unity-ui-specialist, unreal-specialist,
                       ue-blueprint-specialist, ue-gas-specialist,
                       ue-replication-specialist, ue-umg-specialist
```

**조율 규칙:**
- 수직 위임: Directors > Leads > Specialists. 복잡한 결정에서는 계층을 절대
  건너뛰지 않습니다.
- 수평 협의: 같은 계층의 에이전트끼리는 서로 상의할 수 있지만, 자신의
  도메인 밖에서 구속력 있는 결정을 내려서는 안 됩니다.
- 갈등 해결: 설계 갈등은 `creative-director`로. 기술 갈등은
  `technical-director`로. 범위 갈등은 `producer`로.
- 일방적인 도메인 간 변경은 없음.

### 자동화 훅(안전망)

시스템에는 자동으로 실행되는 12개의 훅이 있습니다.

| 훅 | 트리거 | 하는 일 |
|------|---------|-------------|
| `session-start.sh` | 세션 시작 | 브랜치, 최근 커밋을 보여주고 복구를 위해 active.md를 감지 |
| `detect-gaps.sh` | 세션 시작 | 새 프로젝트(엔진 없음, 컨셉 없음)를 감지하고 `/start`를 제안 |
| `pre-compact.sh` | 압축 전 | 자동 복구를 위해 세션 상태를 대화에 덤프 |
| `post-compact.sh` | 압축 후 | Claude에게 `active.md`에서 세션 상태를 복원하라고 알림 |
| `notify.sh` | 알림 이벤트 | PowerShell을 통해 Windows 토스트 알림 표시 |
| `validate-commit.sh` | 커밋 전 | 설계 문서 참조, 유효한 JSON, 하드코딩 값 없음 확인 |
| `validate-push.sh` | 푸시 전 | main/develop으로의 푸시에 경고 표시 |
| `validate-assets.sh` | 커밋 전 | 애셋 네이밍과 크기 확인 |
| `validate-skill-change.sh` | 스킬 파일 작성 시 | `.claude/skills/` 변경 후 `/skill-test` 실행을 권장 |
| `log-agent.sh` | 에이전트 시작 | 감사 추적을 위해 에이전트 호출을 로그로 남김 |
| `log-agent-stop.sh` | 에이전트 종료 | 에이전트 감사 추적을 완성(시작 + 종료) |
| `session-stop.sh` | 세션 종료 | 최종 세션 로깅 |

### 컨텍스트 복원력

**세션 상태 파일:** `production/session-state/active.md`는 살아있는
체크포인트입니다. 주요 마일스톤마다 업데이트하세요. 어떤 중단(압축, 크래시,
`/clear`) 이후에도 이 파일을 가장 먼저 읽으세요.

**증분 작성:** 다중 섹션 문서를 만들 때는 승인 즉시 각 섹션을 파일에
씁니다. 이렇게 하면 완료된 섹션이 크래시와 컨텍스트 압축에도 살아남습니다.
이미 작성된 섹션에 대한 이전 논의는 안전하게 압축할 수 있습니다.

**자동 복구:** `session-start.sh` 훅이 `active.md`를 자동으로 감지하고
미리 보여줍니다. `pre-compact.sh` 훅은 압축 전에 상태를 대화에 덤프합니다.

**스프린트 상태 추적:** `production/sprint-status.yaml`은 기계가 읽을 수
있는 스토리 추적기입니다. `/sprint-plan`(초기화)과 `/story-done`(상태
업데이트)이 이 파일을 씁니다. `/sprint-status`, `/help`, `/story-done`(다음
스토리)이 이 파일을 읽습니다. 취약한 마크다운 스캔을 제거합니다.

### 브라운필드 도입

이미 일부 산출물이 존재하는 기존 프로젝트의 경우:

```
/adopt
```

또는 특정 대상만:

```
/adopt gdds
/adopt adrs
/adopt stories
/adopt infra
```

이 명령어는 기존 산출물을 **존재 여부가 아닌 형식**을 기준으로 감사하고,
격차를 BLOCKING/HIGH/MEDIUM/LOW로 분류하며, 순서화된 마이그레이션 계획을
만들고, `docs/adoption-plan-[date].md`를 작성합니다. 핵심 원칙은 REPLACEMENT가
아닌 MIGRATION입니다 -- 기존 작업물을 절대 다시 만들지 않고, 격차만
채웁니다.

개별 스킬도 소급 보완(retrofit) 모드를 지원합니다.

```
/design-system retrofit design/gdd/combat-system.md
/architecture-decision retrofit docs/architecture/adr-005.md
```

이 명령어들은 어떤 섹션이 존재하고 어떤 섹션이 없는지 감지해 부족한 부분만
채웁니다.

### 게이트 시스템

단계 게이트는 공식 체크포인트입니다. 전환 이름과 함께 `/gate-check`를
실행하세요.

```
/gate-check concept              # Concept -> Systems Design
/gate-check systems-design       # Systems Design -> Technical Setup
/gate-check technical-setup      # Technical Setup -> Pre-Production
/gate-check pre-production       # Pre-Production -> Production
/gate-check production           # Production -> Polish
/gate-check polish               # Polish -> Release
```

**판정:**
- **PASS** -- 모든 요건이 충족됨, 다음 단계로 진행
- **CONCERNS** -- 요건은 충족했지만 인지된 리스크가 있음, 통과 가능
- **FAIL** -- 요건이 충족되지 않음, 구체적인 개선 방안과 함께 진행을 차단

게이트가 통과하면(그때만) `production/stage.txt`가 업데이트되며, 이는
상태줄과 `/help` 동작을 제어합니다.

### 역설계 문서화

설계 문서 없이 존재하는 코드(브라운필드 도입 후 흔함)의 경우:

```
/reverse-document src/gameplay/combat/
```

기존 코드를 읽고 GDD 형식의 설계 문서를 생성합니다.

---

## 부록 A: 에이전트 빠른 참조

### "X를 하고 싶은데 -- 어떤 에이전트를 써야 하나요?"

| 하고 싶은 일... | 에이전트 | 계층 |
|-------------|-------|------|
| 게임 아이디어 떠올리기 | `/brainstorm` skill | -- |
| 게임 메커닉 설계 | `game-designer` | 2 |
| 구체적인 수식/수치 설계 | `systems-designer` | 3 |
| 게임 레벨 설계 | `level-designer` | 3 |
| 루트 테이블/경제 설계 | `economy-designer` | 3 |
| 세계관 구축 | `world-builder` | 3 |
| 대사 작성 | `writer` | 3 |
| 스토리 계획 | `narrative-director` | 2 |
| 스프린트 계획 | `producer` | 1 |
| 크리에이티브 결정 내리기 | `creative-director` | 1 |
| 기술적 결정 내리기 | `technical-director` | 1 |
| 게임플레이 코드 구현 | `gameplay-programmer` | 3 |
| 핵심 엔진 시스템 구현 | `engine-programmer` | 3 |
| AI 동작 구현 | `ai-programmer` | 3 |
| 멀티플레이어 구현 | `network-programmer` | 3 |
| UI 구현 | `ui-programmer` | 3 |
| 개발 도구 제작 | `tools-programmer` | 3 |
| 코드 아키텍처 검토 | `lead-programmer` | 2 |
| 셰이더/VFX 제작 | `technical-artist` | 3 |
| 비주얼 스타일 정의 | `art-director` | 2 |
| 오디오 스타일 정의 | `audio-director` | 2 |
| 사운드 이펙트 설계 | `sound-designer` | 3 |
| UX 플로우 설계 | `ux-designer` | 3 |
| 테스트 케이스 작성 | `qa-tester` | 3 |
| 테스트 전략 계획 | `qa-lead` | 2 |
| 성능 프로파일링 | `performance-analyst` | 3 |
| CI/CD 구축 | `devops-engineer` | 3 |
| 분석(애널리틱스) 설계 | `analytics-engineer` | 3 |
| 접근성 확인 | `accessibility-specialist` | 3 |
| 라이브 오퍼레이션 계획 | `live-ops-designer` | 3 |
| 릴리스 관리 | `release-manager` | 2 |
| 로컬라이제이션 관리 | `localization-lead` | 2 |
| 빠르게 프로토타이핑 | `prototyper` | 3 |
| 보안 감사 | `security-engineer` | 3 |
| 플레이어와 소통 | `community-manager` | 3 |
| Godot 관련 도움 | `godot-specialist` | 3 |
| GDScript 관련 도움 | `godot-gdscript-specialist` | 3 |
| Godot 셰이더 도움 | `godot-shader-specialist` | 3 |
| GDExtension 모듈 | `godot-gdextension-specialist` | 3 |
| Unity 관련 도움 | `unity-specialist` | 3 |
| Unity DOTS/ECS | `unity-dots-specialist` | 3 |
| Unity 셰이더/VFX | `unity-shader-specialist` | 3 |
| Unity Addressables | `unity-addressables-specialist` | 3 |
| Unity UI Toolkit | `unity-ui-specialist` | 3 |
| Unreal 관련 도움 | `unreal-specialist` | 3 |
| Unreal GAS | `ue-gas-specialist` | 3 |
| Unreal Blueprints | `ue-blueprint-specialist` | 3 |
| Unreal 리플리케이션 | `ue-replication-specialist` | 3 |
| Unreal UMG/CommonUI | `ue-umg-specialist` | 3 |

### 에이전트 위계

```
                    creative-director / technical-director / producer
                                         |
          ---------------------------------------------------------------
          |            |           |           |          |        |       |
    game-designer  lead-prog  art-dir  audio-dir  narr-dir  qa-lead  release-mgr
          |            |           |           |          |        |        |
     specialists  programmers  tech-art  snd-design  writer   qa-tester  devops
     (systems,    (gameplay,             (sound)     (world-  (perf,     (analytics,
      economy,     engine,                           builder)  access.)   security)
      level)       ai, net,
                   ui, tools)
```

**에스컬레이션 규칙:** 두 에이전트가 의견이 갈리면 상위로 올리세요. 설계
갈등은 `creative-director`로. 기술 갈등은 `technical-director`로. 범위
갈등은 `producer`로.

---

## 부록 B: 슬래시 명령어 빠른 참조

### 카테고리별 전체 73개 명령어

#### 온보딩과 내비게이션 (6)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/start` | 가이드형 온보딩, 알맞은 워크플로로 안내 | 아무 때나(첫 세션) |
| `/help` | 맥락 기반 "다음에 뭘 해야 하지?" | 아무 때나 |
| `/project-stage-detect` | 현재 단계를 파악하기 위한 전체 프로젝트 감사 | 아무 때나 |
| `/setup-engine` | 엔진 설정, 버전 고정, 환경설정 지정 | 1 |
| `/adopt` | 브라운필드 감사와 마이그레이션 계획 | 아무 때나(기존 프로젝트) |
| `/skill-improve` | test-fix-retest 루프로 스킬 개선 | 아무 때나 |

#### 게임 설계 (6)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/brainstorm` | MDA 분석을 통한 협업형 아이디어 발상 | 1 |
| `/map-systems` | 컨셉을 시스템 인덱스로 분해 | 1-2 |
| `/design-system` | 가이드형 섹션별 GDD 작성 | 2 |
| `/quick-design` | 소규모 변경을 위한 경량 스펙 | 2+ |
| `/review-all-gdds` | 크로스 GDD 일관성 및 디자인 이론 검토 | 2 |
| `/propagate-design-change` | GDD 변경에 영향받는 ADR/스토리 찾기 | 5 |

#### UX와 인터페이스 (2)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/ux-design` | UX 스펙(화면/플로우, HUD, 패턴) 작성 | 4 |
| `/ux-review` | 접근성 및 GDD 정합성을 위해 UX 스펙 검증 | 4 |

#### 아키텍처 (4)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/create-architecture` | 마스터 아키텍처 문서 | 3 |
| `/architecture-decision` | ADR 생성 또는 소급 보완 | 3 |
| `/architecture-review` | 모든 ADR과 의존성 순서 검증 | 3 |
| `/create-control-manifest` | Accepted ADR로부터 프로그래머용 규칙표 생성 | 3 |

#### 스토리와 스프린트 (8)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/create-epics` | GDD + ADR을 에픽으로 변환(모듈당 하나) | 4 |
| `/create-stories` | 하나의 에픽을 스토리 파일로 분해 | 4 |
| `/dev-story` | 스토리 구현 — 알맞은 프로그래머 에이전트로 라우팅 | 5 |
| `/sprint-plan` | 스프린트 계획 생성 또는 관리 | 4-5 |
| `/sprint-status` | 빠른 30줄 스프린트 스냅샷 | 5 |
| `/story-readiness` | 스토리가 구현 준비되었는지 검증 | 4-5 |
| `/story-done` | 8단계 스토리 완료 검토 | 5 |
| `/estimate` | 리스크 평가와 함께 공수 산정 | 4-5 |

#### 검토와 분석 (13)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/design-review` | 8섹션 표준에 대해 GDD 검증 | 1-2 |
| `/code-review` | 아키텍처 코드 리뷰 | 5+ |
| `/balance-check` | 게임 밸런스 수식 분석 | 5-6 |
| `/asset-audit` | 애셋 네이밍, 형식, 크기 검증 | 6 |
| `/asset-spec` | 애셋별 비주얼 스펙과 AI 생성 프롬프트 | 5-6 |
| `/content-audit` | GDD 명시 콘텐츠 대 구현 콘텐츠 비교 | 5 |
| `/consistency-check` | 크로스 GDD 엔티티 및 수식 불일치 스캔 | 2+ |
| `/scope-check` | 범위 크리프 감지 | 5 |
| `/perf-profile` | 성능 프로파일링 워크플로 | 6 |
| `/tech-debt` | 기술 부채 스캔과 우선순위 지정 | 6 |
| `/gate-check` | PASS/CONCERNS/FAIL 공식 단계 게이트 | 모든 전환 |
| `/reverse-document` | 기존 코드로부터 설계 문서 생성 | 아무 때나 |
| `/security-audit` | 보안 취약점 감사(세이브, 네트워크, 입력) | 6-7 |

#### QA와 테스트 (9)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/qa-plan` | 스프린트 또는 기능을 위한 QA 테스트 계획 생성 | 5 |
| `/smoke-check` | QA 인계 전 크리티컬 패스 스모크 테스트 게이트 | 5-6 |
| `/soak-test` | 장시간 플레이 세션을 위한 소크 테스트 프로토콜 | 6 |
| `/regression-suite` | 테스트 커버리지 매핑, 회귀 테스트가 없는 수정된 버그 식별 | 5-6 |
| `/test-setup` | 테스트 프레임워크와 CI/CD 파이프라인 구축 | 4 |
| `/test-helpers` | 엔진별 테스트 헬퍼 라이브러리 생성 | 4-5 |
| `/test-evidence-review` | 테스트 파일과 수동 증거의 품질 검토 | 5 |
| `/test-flakiness` | CI 로그로부터 비결정적 테스트 감지 | 5-6 |
| `/skill-test` | 스킬 파일의 구조적, 행동적 정확성 검증 | 아무 때나 |

#### 프로덕션 관리 (6)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/milestone-review` | 마일스톤 진행 상황과 go/no-go | 5 |
| `/retrospective` | 스프린트 회고 분석 | 5 |
| `/bug-report` | 구조화된 버그 리포트 작성 | 5+ |
| `/bug-triage` | 우선순위, 심각도, 담당자를 기준으로 오픈 버그 재평가 | 5+ |
| `/playtest-report` | 구조화된 플레이테스트 세션 리포트 | 4-6 |
| `/onboard` | 신규 팀원 온보딩 | 아무 때나 |

#### 릴리스 (6)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/release-checklist` | 출시 전 검증 | 7 |
| `/launch-checklist` | 부서 전체 출시 준비도 검증 | 7 |
| `/changelog` | 내부용 체인지로그 자동 생성 | 7 |
| `/patch-notes` | 플레이어 대상 패치 노트 | 7 |
| `/hotfix` | 긴급 수정 워크플로 | 7+ |
| `/day-one-patch` | 골드 마스터 이후 발견된 이슈를 위한 범위 지정 패치 | 7+ |

#### 크리에이티브 (4)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/prototype` | 컨셉 프로토타입 — GDD 작성 전 핵심 아이디어 검증 | 1 |
| `/art-bible` | 가이드형 Art Bible 작성 — 비주얼 아이덴티티 스펙 | 1-2 |
| `/vertical-slice` | Production 전 프로덕션 품질의 엔드투엔드 빌드 | 4 |
| `/localize` | 문자열 추출과 검증 | 6-7 |

#### 팀 오케스트레이션 (9)

| 명령어 | 목적 | 단계 |
|---------|---------|-------|
| `/team-combat` | 전투 기능: 설계부터 구현까지 | 5 |
| `/team-narrative` | 내러티브 콘텐츠: 구조부터 대사까지 | 5 |
| `/team-ui` | UI 기능: UX 스펙부터 다듬어진 구현까지 | 5 |
| `/team-level` | 레벨: 레이아웃부터 드레싱된 인카운터까지 | 5 |
| `/team-audio` | 오디오: 방향성부터 구현된 이벤트까지 | 5-6 |
| `/team-polish` | 조율된 폴리시: perf + art + audio + QA | 6 |
| `/team-release` | 릴리스 조율: build + QA + deployment | 7 |
| `/team-live-ops` | 라이브 오퍼레이션 계획: 시즌 이벤트, 배틀 패스, 리텐션 | 7+ |
| `/team-qa` | 전체 QA 사이클: 전략, 실행, 커버리지, 승인 | 6-7 |

---

## 부록 C: 자주 쓰는 워크플로

### 워크플로 1: "이제 막 시작했고 게임 아이디어가 없어요"

```
1. /start (현재 위치에 따라 안내)
2. /brainstorm (협업형 아이디어 발상, 컨셉 선택)
3. /setup-engine (엔진과 버전 고정)
4. /design-review on concept doc (선택 사항, 권장)
5. /map-systems (컨셉을 의존성과 우선순위를 가진 시스템으로 분해)
6. /gate-check concept (Systems Design 단계 진행 가능 여부 확인)
7. /design-system per system (가이드형 GDD 작성)
```

### 워크플로 2: "설계는 마쳤고 코딩을 시작하고 싶어요"

```
1. /design-review on each GDD (GDD가 탄탄한지 확인)
2. /review-all-gdds (크로스 GDD 일관성)
3. /gate-check systems-design
4. /create-architecture + /architecture-decision (per major decision)
5. /architecture-review
6. /create-control-manifest
7. /gate-check technical-setup
8. /create-epics layer: foundation + /create-stories [slug] (에픽 정의, 스토리로 분해)
9. /sprint-plan new
10. /story-readiness -> implement -> /story-done (스토리 생애주기)
```

### 워크플로 3: "프로덕션 중간에 복잡한 기능을 추가해야 해요"

```
1. /design-system or /quick-design (규모에 따라)
2. /design-review to validate
3. /propagate-design-change if modifying existing GDDs
4. /estimate for effort and risk
5. /team-combat, /team-narrative, /team-ui, etc. (해당하는 팀 스킬)
6. /story-done when complete
7. /balance-check if it affects game balance
```

### 워크플로 4: "프로덕션에서 무언가 고장났어요"

```
1. /hotfix "description of the issue"
2. Fix is implemented on hotfix branch
3. /code-review the fix
4. Run tests
5. /release-checklist for hotfix build
6. Deploy and backport
```

### 워크플로 5: "기존 프로젝트가 있고 이 시스템을 쓰고 싶어요"

```
1. /start (경로 D 선택 -- 기존 작업물)
2. /project-stage-detect (현재 단계 파악)
3. /adopt (기존 산출물 감사, 마이그레이션 계획 수립)
4. /design-system retrofit [path] (GDD 격차 채우기)
5. /architecture-decision retrofit [path] (ADR 격차 채우기)
6. /gate-check at appropriate transition
```

### 워크플로 6: "새 스프린트 시작"

```
1. /retrospective (지난 스프린트 검토)
2. /sprint-plan new (다음 스프린트 생성)
3. /scope-check (범위가 관리 가능한지 확인)
4. /story-readiness per story before pickup
5. Implement stories
6. /story-done per completed story
7. /sprint-status for quick progress checks
```

### 워크플로 7: "게임 출시하기"

```
1. /gate-check polish (Polish 단계가 완료되었는지 확인)
2. /tech-debt (출시 시점에 감수할 수 있는 것을 결정)
3. /localize (최종 로컬라이제이션 패스)
4. /release-checklist v1.0.0
5. /launch-checklist (부서 전체 검증)
6. /team-release (릴리스 조율)
7. /patch-notes and /changelog
8. Ship!
9. /hotfix if anything breaks post-launch
10. Post-mortem after launch stabilizes
```

### 워크플로 8: "길을 잃었어요 / 다음에 뭘 해야 할지 모르겠어요"

```
1. /help (현재 단계를 읽고, 산출물을 확인하고, 다음 할 일을 알려줌)
2. If /help doesn't help: /project-stage-detect (전체 감사)
3. If stage seems wrong: /gate-check at the transition you think you're at
```

---

## 시스템을 최대한 활용하기 위한 팁

1. **항상 설계를 먼저 하고 나서 구현하세요.** 이 에이전트 시스템은 코드를
   작성하기 전에 설계 문서가 존재한다는 전제로 만들어졌습니다. 에이전트는
   GDD를 끊임없이 참조합니다.

2. **여러 영역에 걸친 기능에는 팀 스킬을 사용하세요.** 4명의 에이전트를
   직접 수동으로 조율하려 하지 말고 -- `/team-combat`, `/team-narrative`
   등이 오케스트레이션을 처리하도록 맡기세요.

3. **규칙 시스템을 신뢰하세요.** 규칙이 코드에서 무언가를 표시하면
   고치세요. 규칙들은 힘들게 얻은 게임 개발 지혜(데이터 기반 값, 델타
   타임, 접근성 등)를 담고 있습니다.

4. **미리미리 압축하세요.** 컨텍스트 사용량이 약 65~70%에 도달하면 압축하거나
   `/clear`를 실행하세요. pre-compact 훅이 진행 상황을 저장해 줍니다. 한계에
   도달할 때까지 기다리지 마세요.

5. **알맞은 계층의 에이전트를 사용하세요.** `creative-director`에게 셰이더를
   써달라고 하지 마세요. `qa-tester`에게 설계 결정을 내려달라고 하지 마세요.
   위계는 이유가 있어서 존재합니다.

6. **확신이 없을 때는 /help를 실행하세요.** 실제 프로젝트 상태를 읽고 가장
   중요한 다음 한 걸음을 알려줍니다.

7. **설계를 프로그래머에게 넘기기 전에 `/design-review`를 실행하세요.**
   불완전한 스펙을 조기에 잡아내 재작업을 줄여줍니다.

8. **모든 주요 기능 이후에 `/code-review`를 실행하세요.** 아키텍처 문제가
   확산되기 전에 잡아내세요.

9. **위험한 메커닉은 먼저 프로토타이핑하세요.** 하루의 프로토타이핑이
   작동하지 않는 메커닉에 들어갈 일주일의 프로덕션 시간을 아껴줄 수
   있습니다.

10. **스프린트 계획을 정직하게 유지하세요.** `/scope-check`를 정기적으로
    사용하세요. 범위 크리프는 인디 게임을 죽이는 가장 큰 원인입니다.

11. **ADR로 결정을 문서화하세요.** 미래의 당신은 지금의 당신에게 왜 그렇게
    만들었는지 기록해 준 것에 감사할 것입니다.

12. **스토리 생애주기를 철저히 지키세요.** 착수 전 `/story-readiness`,
    완료 후 `/story-done`. 이는 이탈을 조기에 잡아내고 파이프라인을
    정직하게 유지합니다.

13. **일찍, 자주 파일에 기록하세요.** 섹션 단위 증분 작성은 설계 결정이
    크래시와 압축에도 살아남는다는 뜻입니다. 파일이 곧 기억이며,
    대화가 아닙니다.
