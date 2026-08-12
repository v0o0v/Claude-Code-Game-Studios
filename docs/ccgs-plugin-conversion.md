# CCGS 플러그인 전환 — 계획 및 수직 슬라이스 검증 보고서

**상태**: 수직 슬라이스 검증 완료, 전체 롤아웃(52개 에이전트·70개 스킬·11개 규칙·엔진 레퍼런스 4팩) 착수 대기.
**작성일**: 2026-08-13
**목적**: 이 문서 하나로 다음 세션이 처음부터 grill-me를 다시 하지 않고 바로 전체 롤아웃에 들어갈 수 있게 한다.

---

## 1. 왜 이 작업을 하는가

현재 리포는 `.claude/` 아래에 에이전트 56개·스킬 73개·훅 12개·규칙 11개가 있는 **템플릿 리포**다.
다른 프로젝트에서 이걸 쓰려면 리포 전체를 복제해야 한다. 이를 Claude Code **플러그인**으로 바꿔서
`claude plugin install ccgs@<marketplace>` 한 번으로 어느 프로젝트에서든 `/ccgs:brainstorm` 같은
명령을 쓸 수 있게 만드는 것이 목표.

## 2. 확정된 아키텍처 결정 (grill-me 세션 결과, 전부 확정됨 — 재논의 불필요)

| # | 결정 | 이유/근거 |
|---|------|-----------|
| 1 | **경계**: 플러그인은 읽기 전용 동작(agents/skills/hooks/템플릿)만. 프로젝트별 가변 파일은 부트스트랩이 스캐폴드 | 플러그인 캐시(`${CLAUDE_PLUGIN_ROOT}`)는 업데이트 시 GC됨 — 쓰기 불가 |
| 2 | **레이아웃 고정**: `design/gdd/`, `production/`, `docs/architecture/`, `tests/` 등 현재 구조 그대로 강제 | 73개 스킬에 이미 경로가 하드코딩돼 있음(`design/gdd/` 73회 등) |
| 3 | **상시 컨텍스트**: 부트스트랩(`/ccgs:init`)이 소비 프로젝트 `CLAUDE.md`에 `<!-- CCGS:BEGIN -->...<!-- CCGS:END -->` 마커 블록을 직접 텍스트로 주입 | 플러그인 루트의 CLAUDE.md는 프로젝트 컨텍스트로 로드되지 않음(공식 문서 확인) |
| 4 | **전환 방식**: bare 이름(`producer`, `/design-system` 등) → `ccgs:` 네임스페이스로 **수동 전면 전환** | 자동화 스크립트로 처리하기엔 문맥 판단(코드 vs 프로즈, 이미 포함된 팩 vs 아직 없는 것)이 필요 |
| 5 | **upstream**: `Donchitos/Claude-Code-Game-Studios` 추적 중단, 독립 포크로 선언 | 전환 후 거의 모든 스킬 파일이 upstream과 충돌하게 됨 |
| 6 | **플러그인 이름**: `ccgs` | 짧고, 리포 안에서 이미 CCGS 약어로 쓰이고 있었음 |
| 7 | **엔진 레퍼런스**: 플러그인이 godot/unity/unreal/web 4팩 보유, `/ccgs:setup-engine`이 선택한 엔진만 프로젝트로 복사 | `VERSION.md`는 프로젝트별로 갱신되는 가변 파일이라 플러그인 캐시에 못 둠 |
| 8 | **permissions·statusLine**: 플러그인 탑재 불가 → `/ccgs:init`이 프로젝트 `settings.json`에 병합 제안 | 플러그인은 permissions를 선언할 수 없음(공식 확인) |
| 9 | **리포 구조**: 같은 리포 `plugin/` 서브디렉터리 + 루트 `.claude-plugin/marketplace.json` | 마이그레이션 난이도 최소, 별도 리포 분리 대비 관리 대상 하나 |
| 10 | **언어 정책**: 프롬프트(스킬·에이전트 본문)는 영문 유지, 사용자 대면(README·설치 안내·부트스트랩 대화)은 한글 | 프롬프트 번역 시 동작이 미묘하게 바뀌는 리스크가 129개 파일 규모에서 감당 불가 |
| 11 | **Skill Testing Framework**: 배포 제외, 리포에 개발용으로만 유지 | 사용자에게 불필요, 배포물 용량·범위만 키움 |
| 12 | **부트스트랩 트리거**: `/ccgs:init`이 마커(`.ccgs/config.yaml`) 생성 → 이후 마커 있는 프로젝트에서만 `SessionStart` 훅이 자동 복구·갱신(매번 재확인 없이) | 무관한 리포를 열었을 때 자동으로 디렉터리를 만드는 사고 방지 |
| 13 | **실행 순서**: 수직 슬라이스(스킬 3 + 에이전트 4 + 훅 1) 먼저 검증 → 확정된 문법으로 나머지 일괄 적용 | 미검증 문법이 틀리면 재작업 범위가 최대가 됨 — **이 문서가 그 검증 결과** |

## 3. 수직 슬라이스 — 무엇을 만들었고 무엇을 검증했나

### 3.1 만든 것 (현재 `plugin/`, `.claude-plugin/` 에 이미 존재, 커밋은 별도 브랜치)

```
.claude-plugin/marketplace.json          # 마켓플레이스 정의 (source: "./plugin" — 문자열!)
plugin/.claude-plugin/plugin.json        # 플러그인 매니페스트
plugin/agents/
  creative-director.md
  art-director.md
  technical-director.md
  producer.md
plugin/skills/
  init/SKILL.md                          # 신규 작성 — 부트스트랩 스킬
  brainstorm/SKILL.md                    # 원본에서 변환
  map-systems/SKILL.md                   # 원본에서 변환
plugin/hooks/
  hooks.json
  scripts/session-start.sh               # 마커 게이팅 로직
plugin/docs/                             # 정적 참조 문서 (읽기 전용, 플러그인 상주)
  director-gates.md, coordination-rules.md, coding-standards.md,
  context-management.md, directory-structure.md
plugin/templates/                        # 프로젝트로 복사되는 템플릿
  game-concept.md, systems-index.md, technical-preferences.md(빈 템플릿),
  settings-additions.json (permissions.deny 블록)
```

### 3.2 실제 설치·실행으로 검증한 것 (전부 통과)

`claude plugin marketplace add ./` → `claude plugin install ccgs@ccgs-marketplace` (user scope)로
실제 설치한 뒤, 별도 스크래치 프로젝트에서 `claude -p`로 확인:

1. **스킬 네임스페이스**: `/ccgs:brainstorm`, `/ccgs:init`, `/ccgs:map-systems` 전부 인식됨
2. **에이전트 네임스페이스**: `subagent_type: ccgs:producer` 등 4개 전부 인식, 올바른 파일 로드
3. **에이전트 페르소나 정확성**: `ccgs:producer`에게 창작 결정을 물었더니 실제로 거부하고
   `ccgs:creative-director`로 에스컬레이션 — **스스로 생성한 텍스트에서 네임스페이스를 붙여서 언급함**.
   수동 치환이 실제 동작에 반영된다는 직접 증거.
4. **`SessionStart` 훅 마커 게이팅**: 마커 없으면 힌트 한 줄만 출력하고 아무 것도 안 씀. 마커 있으면
   `=== Claude Code Game Studios (ccgs) ===` 배너 + 누락 디렉터리 자동 복구.
5. **`/ccgs:init` 승인 게이트**: 승인 전 `find`로 확인 시 파일 0개. 승인 후에만 정확히 11개 디렉터리 +
   `.ccgs/config.yaml` + `CLAUDE.md` 블록 + 참조 문서 5종 + `production/review-mode.txt` 생성.
6. **`CLAUDE.md` 마커 블록 + `@`-import**: 주입된 블록의 `@.claude/docs/coordination-rules.md`가
   실제로 세션 시작 시 자동 로드됨 — Claude가 그 파일의 "병렬 스폰 규칙"을 지시 없이 정확히 알고 있었음.
7. **`${CLAUDE_PLUGIN_ROOT}` 치환**: `plugin/skills/map-systems/SKILL.md` 안의
   `${CLAUDE_PLUGIN_ROOT}/docs/director-gates.md`가 실제로
   `~/.claude/plugins/cache/ccgs-marketplace/ccgs/0.1.0/docs/director-gates.md`로 resolve됨.

### 3.3 검증 과정에서 잡은 실제 버그 1건

**`marketplace.json`의 `source` 필드는 객체가 아니라 문자열이다.**
1차 조사(claude-code-guide 서브에이전트)는 `{"source": "directory", "path": "./plugin"}` 형태라고
보고했는데, 실제 설치 시 `claude plugin install`이 "source type your Claude Code version does not
support"로 실패했다. 재조사 결과 정답은:
```json
{ "name": "ccgs", "source": "./plugin" }
```
→ **교훈**: 문서 조사만으로 결론 내지 말고, 반드시 실제 설치로 검증할 것. 전체 롤아웃 시에도 이 방식
(작게 만들고 실제로 설치해서 확인) 유지.

### 3.4 검증하지 않고 넘어간 것 (알려진 갭)

- **`statusLine` 병합**: `/ccgs:init`의 Phase 5에서 의도적으로 제외했다. 프로젝트 `settings.json`에
  쓰는 커맨드 문자열 안에서 `${CLAUDE_PLUGIN_ROOT}`가 실행 시점에 정상 치환되는지 미검증. 전체
  롤아웃 전에 별도로 확인 필요.
- **`skills:` 프론트매터 필드의 네임스페이스 효과**: `creative-director.md`의
  `skills: [ccgs:brainstorm, ccgs:design-review]`가 실제로 그 에이전트의 스킬 접근을 제한/허용하는
  근거로 동작하는지는 검증하지 않았다(문서화되지 않은 필드). 접두사는 일관성을 위해 붙였지만, 틀려도
  안전하게 실패할 것으로 예상(단순히 그 스킬이 안 보이는 정도).
- **`brainstorm`/`map-systems`의 전체 인터랙티브 플로우**: 6단계짜리 실제 대화 흐름(AskUserQuestion
  다회 왕복 포함)은 끝까지 돌려보지 않았다. 네임스페이스 해석과 승인 게이트만 확인했다.
- **컨텍스트 비용 실측**: `claude plugin details`가 이 4-슬라이스 기준 상시 컨텍스트 ~635 토큰이라고
  보고했다. 56 에이전트 + 73 스킬 전체로 선형 확장하면 대략 1만~1.5만 토�큰 규모로 추정되나 실측 아님.

## 4. 검증된 전환 규칙 (전체 롤아웃 시 그대로 적용)

수직 슬라이스에서 사용한 정확한 sed 패턴 (bash, `SKILLS`/`AGENTS` 변수는 전체 목록으로 확장):

```bash
# 1. 에이전트 백틱 참조: `producer` → `ccgs:producer`
#    (프론트매터 name: 줄은 반드시 bare 유지 — 플러그인이 자동으로 스코프를 붙임)
sed -i "s/\`${a}\`/\`ccgs:${a}\`/g; s/(delegate to ${a})/(delegate to ccgs:${a})/g; \
        s/(coordinate with ${a})/(coordinate with ccgs:${a})/g; \
        s/Reports to: \`${a}\`/Reports to: \`ccgs:${a}\`/g" "$f"

# 2. 슬래시 명령: /skill-name → /ccgs:skill-name (경로 파편과 구분 위해 단어 경계 필수)
sed -i -E "s@(^|[^a-zA-Z0-9:_-])/${s}([^a-zA-Z0-9_-]|$)@\1/ccgs:${s}\2@g" "$f"

# 3. 플러그인 상주 정적 문서 경로: .claude/docs/X.md → ${CLAUDE_PLUGIN_ROOT}/docs/X.md
#    (technical-preferences.md 처럼 프로젝트가 쓰는 파일은 이 치환 대상이 아님 — project-relative 유지)
sed -i 's|`\.claude/docs/director-gates\.md`|`${CLAUDE_PLUGIN_ROOT}/docs/director-gates.md`|g' "$f"
```

**주의사항 (실전에서 확인된 함정)**:
- `producer` 같은 흔한 영단어가 포함된 에이전트명은 치환 전 반드시 `grep -n`으로 오탐 확인
  (이번엔 오탐 0건이었지만 다른 에이전트명—예: `writer`, `world-builder`—은 재확인 필요)
- `` `/architecture-decision (×N)` ``처럼 스킬명 뒤에 공백+텍스트가 붙은 경우, 백틱 직후 종료를
  가정하는 sed는 놓친다 — 반드시 위 2번의 단어 경계 패턴 사용
- 이중 접두(`ccgs:ccgs:`) 방지를 위해 치환 후 반드시 `grep -c "ccgs:ccgs:"`로 0건 확인
- `design/gdd/`, `production/review-mode.txt` 같은 **프로젝트 상대경로는 손대지 말 것** — 결정 #2로
  레이아웃이 고정이므로 그대로 유지

## 5. 전체 롤아웃 남은 작업 (다음 세션 시작점)

1. **에이전트 52개** 추가 변환 (godot/unity/unreal/web 엔진 전문가 포함) — 각 파일의
   Delegation Map, `skills:` 프론트매터, 본문 내 백틱 참조를 §4 규칙으로 전환
2. **스킬 70개** 추가 변환 — 슬래시 명령 참조(~470건 중 이미 처리한 걸 뺀 나머지)와 에이전트
   스폰 참조(~659건 중 나머지) 전환. `.claude/docs/*.md` 경로 → `${CLAUDE_PLUGIN_ROOT}/docs/*.md`
   또는 프로젝트 스캐폴드 경로로 분기(정적 문서 vs `technical-preferences.md`처럼 가변 문서 구분)
3. **규칙 11개** (`.claude/rules/*.md`, `paths:` 프론트매터) — 플러그인 컴포넌트 타입이 아님이 확인됨.
   `/ccgs:init`이 프로젝트 `.claude/rules/`로 복사하는 방식으로 처리(엔진 레퍼런스와 동일 패턴)
4. **엔진 레퍼런스 4팩** (godot 12 / unity 16 / unreal 17 / web 13 = 58문서) — `/ccgs:setup-engine`
   스킬 자체를 아직 변환 안 함. 변환 시 "선택한 엔진만 프로젝트로 복사" 로직 구현 필요
5. **`/ccgs:init` 확장**: 지금은 §2의 뼈대만 구현. 전체 롤아웃 시 통합할 것:
   - `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`(687줄) 전체를 프로젝트로 복사할지, 마커 블록의
     4줄 요약으로 계속 충분할지 재검토
   - `statusLine` 병합 (§3.4 갭 해소 후)
6. **README·설치 안내**: 결정 #10에 따라 사용자 대면 문서 작성 (한글) —
   `claude plugin marketplace add v0o0v/Claude-Code-Game-Studios` 형태의 실제 설치 커맨드 포함
   (현재는 로컬 상대경로 `./`로만 테스트함 — 원격 설치는 미검증)
7. **CCGS Skill Testing Framework 134파일**: 결정 #11에 따라 배포 제외, 리포에 그대로 유지

## 6. 현재 git 상태

`plugin/`, `.claude-plugin/`은 현재 `main` 브랜치에 **커밋되지 않은 상태**로 존재한다(작업 보존을
위해 별도 브랜치로 옮길 예정). 테스트로 설치한 `ccgs@ccgs-marketplace`는 이 머신의 user 스코프에
계속 활성화되어 있다(요청에 따라 유지 — 무관한 프로젝트를 열어도 마커 없으면 훅이 한 줄 안내만 함).
