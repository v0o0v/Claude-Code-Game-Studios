# 예시 세션: /adopt — 브라운필드 프로젝트 온보딩

**맥락:** 개발자가 이 에이전트 시스템을 발견하기 전 3개월간 게임을 만들어 왔습니다. 코드와 일부 디자인 문서, 러프한 메모가 있지만 — 스킬들이 사용할 수 있는 올바른 형식은 아무것도 없습니다.

**시작 상태:**
- `src/gameplay/` — 약 4000줄의 Godot 4.6 GDScript
- `design/` — 러프한 디자인 메모가 담긴 마크다운 파일 3개(GDD 템플릿 형식이 아님)
- `design/gdd/` 디렉터리 없음
- `docs/architecture/` 디렉터리 없음
- `production/` 디렉터리 없음
- `design/gdd/systems-index.md` 없음
- CLAUDE.md 존재(엔진 설정됨: Godot 4.6)

**세션 소요 시간:** 약 30분
**턴 수:** 8
**결과:** 도입 계획이 작성되고, 가장 시급한 격차(시스템 인덱스 누락)가 즉시 해결됨

---

## 턴 1: 사용자가 /adopt 실행

**사용자:**
> /adopt

## 턴 2: 에이전트가 프로젝트 상태 감지

**에이전트 (technical-director, /adopt 경유, 컨텍스트: fork):**
> 브라운필드 감사를 실행 중입니다...
>
> **1단계: 프로젝트 상태 감지**
>
> | 산출물 카테고리 | 존재 여부 | 비고 |
> |------------------|-------|-------|
> | 엔진 설정 | ✅ | CLAUDE.md 에 Godot 4.6 |
> | 소스 코드 | ✅ | `src/gameplay/` 에 약 4000줄 |
> | 디자인 문서 | ⚠️ | `design/` 에 파일 3개, GDD 형식 아님 |
> | 아키텍처 문서 | ❌ | `docs/architecture/` 없음 |
> | 시스템 인덱스 | ❌ | `design/gdd/systems-index.md` 없음 |
> | 프로덕션 추적 | ❌ | `production/` 디렉터리 없음 |
> | 스프린트/스토리 파일 | ❌ | 없음 |
>
> **2단계: 형식 감사(기존 파일)**
>
> 디자인 파일 3개의 내부 구조를 확인 중...
>
> *`design/combat-notes.md`:*
> - 비공식적인 메모만 있고, GDD 템플릿 섹션 없음
> - 포함된 내용: 몇 가지 규칙 설명, 데미지 공식, 러프한 밸런스 수치
> - GDD 템플릿에서 누락: Overview, Player Fantasy, Edge Cases, Dependencies, Tuning Knobs, Acceptance Criteria(8개 중 6개 섹션)
>
> *`design/crafting-ideas.md`:*
> - 브레인스토밍 스타일의 메모, 구조 없음
> - 공식 없음, 인수 조건 없음
> - 초기 콘셉트 사고를 담고 있음 — GDD의 입력 자료로는 유용하지만 아직 GDD는 아님
>
> *`design/inventory.md`:*
> - GDD에 가장 가까움 — Overview 와 Rules 섹션이 있음
> - 누락: Player Fantasy, Formulas, Edge Cases, Tuning Knobs, Acceptance Criteria(8개 중 5개 섹션)
>
> **3단계: 격차 분류**
>
> | 격차 | 심각도 | 이유 |
> |-----|----------|--------|
> | 시스템 인덱스 없음 | BLOCKING | `/design-system`, `/create-stories`, `/gate-check` 모두 이것을 필요로 함 |
> | GDD 파일이 템플릿 형식이 아님 | HIGH | 형식이 어긋난 GDD에서는 스킬이 TR-ID를 참조할 수 없음 |
> | 아키텍처 문서 없음 | HIGH | `/architecture-review` 또는 `/create-control-manifest` 를 실행할 수 없음 |
> | 프로덕션 추적 없음 | MEDIUM | 스프린트와 스토리 스킬이 동작하지 않지만, 프로덕션 단계 전까지는 필요하지 않음 |
> | `design/crafting-ideas.md` — GDD 이전 단계 콘텐츠 | LOW | 입력 자료로는 유용함; 이것이 무언가를 막기 전에 전체 GDD 작성이 필요함 |

## 턴 3: 에이전트가 마이그레이션 계획 제시

**에이전트:**
> **4단계: 마이그레이션 계획**
>
> 프로젝트를 완전히 정렬시키기 위한 순서형 7단계입니다. 기존 콘텐츠는 절대 덮어쓰지 않습니다 — 각 단계는 격차만 채웁니다.
>
> | # | 단계 | 스킬 | 우선순위 | 비고 |
> |---|------|-------|----------|-------|
> | 1 | `design/gdd/systems-index.md` 생성 | `/map-systems` 또는 `/adopt` 인라인 | BLOCKING | 하위 스킬 전체를 해제함 |
> | 2 | `design/inventory.md` → GDD 형식으로 리트로핏 | `/design-system retrofit design/inventory.md` | HIGH | 누락된 5개 섹션 추가, 기존 내용 유지 |
> | 3 | `design/combat-notes.md` → GDD 형식으로 리트로핏 | `/design-system retrofit design/combat-notes.md` | HIGH | 누락된 6개 섹션 추가 |
> | 4 | `design/crafting-ideas.md` → 완전한 GDD로 변환 | `/design-system crafting`(신규 작성, 아이디어를 입력으로 사용) | MEDIUM | 리트로핏이 아님 — 리트로핏하기엔 너무 비공식적임 |
> | 5 | 기존 코드로부터 아키텍처 ADR 생성 | `/reverse-document` + `/architecture-decision` | HIGH | 이미 코드에 내려진 결정을 포착함 |
> | 6 | 마스터 아키텍처 문서 생성 | `/create-architecture` | HIGH | ADR 이후 진행 |
> | 7 | 프로덕션 추적 설정 | `/sprint-plan new` | MEDIUM | 아키텍처 단계 이후 진행 |
>
> **중요:** 1단계는 다른 모든 단계보다 먼저 이루어져야 합니다. 나머지는 우선순위에 따라 병렬로 진행하거나 순서를 바꿔도 됩니다.
>
> `docs/adoption-plan-2026-03-12.md` 에 이 계획을 작성해도 될까요?

**사용자:**
> 네. 작성하세요.

**에이전트가 도입 계획을 작성함.**

## 턴 4: 에이전트가 가장 시급한 격차 해결 제안

**에이전트:**
> BLOCKING 격차는 `design/gdd/systems-index.md` 누락입니다.
>
> 기존 코드와 디자인 문서를 읽어 어떤 시스템을 만드셨는지 추론해서 지금 바로 하나 만들어드릴 수 있습니다. `/map-systems` 를 처음부터 실행하는 것보다 빠릅니다 — 이미 존재하는 것을 바탕으로 채워드리면, 확인하시거나 조정하시면 됩니다.
>
> 지금 해드릴까요?

**사용자:**
> 네, 해주세요.

## 턴 5: 에이전트가 코드베이스를 읽고 시스템 인덱스 초안 작성

**에이전트:**
> `src/gameplay/` 를 읽어 시스템을 추론 중...
>
> 코드에서 다음과 같은 시스템 경계를 발견했습니다:
>
> - `src/gameplay/combat/` — 데미지 계산, 히트 감지, 상태 효과
> - `src/gameplay/inventory/` — 아이템 관리, 무게, 스택
> - `src/gameplay/crafting/` — 레시피 조회, 결과 생성(인벤토리 참조)
> - `src/gameplay/movement/` — CharacterBody2D, 지형 수정자(전투에서 위치 계산용으로 참조됨)
> - `src/gameplay/ui/` — HUD, 인벤토리 화면, 대화 박스
> - `src/gameplay/world/` — 타일맵, 지형 타입, 청크 로딩
>
> **시스템 인덱스 초안:**
>
> | 시스템 | 카테고리 | 우선순위 | 의존성 | GDD 상태 |
> |--------|----------|----------|--------------|------------|
> | Movement | Foundation | MVP | 없음 | ❌ 없음 |
> | World/Terrain | Foundation | MVP | Movement | ❌ 없음 |
> | Combat | Core | MVP | Movement | ⚠️ 리트로핏 필요 |
> | Inventory | Core | MVP | 없음 | ⚠️ 리트로핏 필요 |
> | Crafting | Feature | MVP | Inventory | ❌ GDD 이전 단계만 존재 |
> | UI / HUD | Presentation | MVP | Combat, Inventory, Movement | ❌ 없음 |
>
> 이렇게 맞나요? 빠졌거나 잘못 분류된 게 있나요?

**사용자:**
> 맞아요. Stamina 시스템을 추가해주세요 — combat/ 안에 있긴 한데 별도 시스템이어야 해요.

**에이전트:**
> Stamina 를 Core / MVP 시스템으로 추가했습니다:
>
> | Stamina | Core | MVP | Movement, Combat | ❌ 없음 |
>
> 의존성 갱신: Movement 가 Stamina 에 의존함(이동이 스태미나를 소모함).
>
> `design/gdd/systems-index.md` 에 이 내용을 작성해도 될까요?

## 턴 6: 사용자가 승인

**사용자:**
> 네

**에이전트가 `design/gdd/systems-index.md` 를 작성함.**

## 턴 7: 에이전트가 이제 무엇이 해제되었는지 보여줌

**에이전트:**
> `design/gdd/systems-index.md` 가 생성되었습니다.
>
> **BLOCKING 격차가 해결되었습니다.** 이제 다음 스킬들을 실행할 수 있습니다:
>
> - ✅ `/design-system [name]` — 모든 시스템에 대한 가이드형 GDD 작성
> - ✅ `/design-system retrofit [path]` — 기존 문서의 누락 섹션 채우기
> - ✅ `/gate-check` — 이제 검증할 시스템 인덱스가 존재함
> - ✅ `/help` — 이제 올바른 단계 워크플로를 보여줄 수 있음
>
> **권장 다음 단계(도입 계획에 따름):**
>
> 1. `/design-system retrofit design/inventory.md` 실행 — 가장 완성도 높은 기존 문서라 가장 쉬운 승리
> 2. `/design-system retrofit design/combat-notes.md` 실행
> 3. `/design-system crafting` 실행 — 아이디어 파일을 입력으로 활용해 제작 GDD 작성
>
> 이 3개를 마치면 7개 시스템 중 5개가 완전한 GDD를 갖추게 됩니다. 그 다음 `/review-all-gdds` 를 실행해 아키텍처 작업 전에 시스템 간 일관성 문제를 잡아내세요.

## 턴 8: 사용자가 계획 확인

**사용자:**
> 좋아요. 인벤토리 리트로핏부터 시작할게요.

**에이전트:**
> 다음을 실행하세요:
> ```
> /design-system retrofit design/inventory.md
> ```
>
> 스킬이 기존 Overview 와 Rules 섹션을 감지하고, 8개 섹션 중 어떤 것이 누락됐는지 보여준 다음, 격차에 대해서만 섹션 순환을 실행합니다. 기존 내용은 건드리지 않습니다.

---

## 이 예시가 보여주는 것

- **FORMAT 감사, 존재 감사가 아님**: `/adopt` 는 단순히 파일 존재 여부만 확인하지 않고, 내부 구조가 스킬이 기대하는 바와 일치하는지 확인합니다. `gdd.md` 라는 이름의 파일에 템플릿 섹션이 없다면 격차로 플래그됩니다.
- **덮어쓰기가 아닌 마이그레이션**: 기존 콘텐츠는 절대 덮어쓰지 않습니다. 계획은 격차만 채웁니다.
- **BLOCKING 격차가 먼저 드러남**: 시스템 인덱스 누락은 가장 많은 스킬의 동작을 막기 때문에 BLOCKING 으로 식별됩니다.
- **시급한 격차의 즉시 처리**: 단순히 격차를 보고하는 데 그치지 않고, 에이전트가 같은 세션 안에서 즉시 해결을 제안합니다.
- **코드로부터 추론됨**: 시스템 인덱스는 처음부터 작성되는 게 아니라 코드베이스 구조로부터 부트스트랩됩니다 — 브라운필드 코드는 이미 답을 담고 있습니다.
- **리트로핏 vs. 신규 작성**: `/design-system retrofit` 은 기존에 있지만 불완전한 문서를 다루고, 전체 `/design-system` 은 완전히 새로운 문서를 다룹니다. 도입 계획은 각 파일에 어느 쪽이 적용되는지 구분합니다.
- **컨텍스트: fork**: `/adopt` 는 전체 코드베이스에 걸친 대규모 파일 읽기로 메인 세션을 오염시키지 않기 위해 포크된 컨텍스트에서 실행됩니다.
</content>
