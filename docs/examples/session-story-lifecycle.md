# 예시 세션: 스토리 전체 생애주기 — /story-readiness → 구현 → /story-done

**맥락:** 1인 인디 개발자, 프로덕션 스프린트 중반. 이동 시스템 GDD와 아키텍처가 완료됨. `/create-stories`가 이동 시스템 핵심 구현을 위한 스토리를 생성함.

**시작 상태:**
- `design/gdd/movement-system.md` — 완료, 8개 섹션 모두 작성됨
- `docs/architecture/movement-adr-001.md` — Status: Accepted
- `production/sprints/sprint-03.md` — 백로그에 STORY-MOV-001 등록됨
- `production/stories/STORY-MOV-001.md` — 존재하지만 아직 검증되지 않음
- 구현 코드 없음

**세션 소요 시간:** 약 50분
**턴 수:** 13
**결과:** 스토리가 준비 완료로 검증되고, 구현되고, `/story-done`으로 완료 확인됨

---

## 1단계: 스토리 준비 상태 확인

### 턴 1: 사용자가 준비 상태 확인을 실행함

**사용자:**
> /story-readiness production/stories/STORY-MOV-001.md

### 턴 2: 에이전트가 스토리를 검증함

**에이전트 (/story-readiness 경유):**
> `production/stories/STORY-MOV-001.md` 읽는 중...
>
> **STORY-MOV-001: 지형 보정을 포함한 CharacterBody2D 이동 구현**
>
> 검증 항목 4가지를 확인합니다:
>
> **1. 설계 완결성**
> - GDD 참조: `design/gdd/movement-system.md` ✅
> - GDD 섹션 커버리지: Detailed Rules ✅, Formulas ✅, Edge Cases ✅
> - TR-ID 임베드됨: TR-MOV-001부터 TR-MOV-008까지 ✅
>
> **2. 아키텍처 완결성**
> - ADR 참조: `docs/architecture/movement-adr-001.md` ✅
> - ADR 상태: **Accepted** ✅ *(Proposed였다면 BLOCKED였을 것)*
> - 스토리 내 컨트롤 매니페스트 버전: `2026-03-10` — 현재 매니페스트도 `2026-03-10` ✅
>
> **3. 범위 명확성**
> - 승인 기준: 9개 항목, 모두 측정 가능 ✅
> - 범위 외 항목 명시: 수영, 등반 ✅
> - 발견된 모호함: **1건**
>   - ⚠️ 스토리에는 "구르기 방향은 마지막 입력 방향을 따른다"고 되어 있지만 GDD에는 "이동 방향으로 구른다"고 되어 있음 — 플레이어가 멈춘 직후 바로 구를 때 이 둘이 충돌함. 착수 전에 명확히 해야 함.
>
> **4. 완료 정의**
> - 필요한 테스트: 공식 함수에 대한 단위 테스트 ✅
> - 연동 시그널: `on_stamina_event`가 올바르게 발생해야 함 ✅
>
> ---
> **판정: NEEDS WORK**
>
> 구현을 시작하기 전에 모호함 한 건을 해결해야 합니다. 지금 해결해서 스토리를 준비 완료로 표시할까요?

### 턴 3: 사용자가 모호함을 해결함

**사용자:**
> 구르기는 마지막 이동 방향을 사용해요. 플레이어가 정지 상태라면 대신 바라보고 있는 방향을 사용하고요.

### 턴 4: 에이전트가 스토리를 업데이트함

**에이전트:**
> 스토리의 Detailed Rules 섹션을 업데이트하겠습니다:
>
> > 구르기 방향: 마지막 이동 방향. 구르기 입력 시점에 속도가 0이면 현재 바라보는 방향을 사용.
>
> 이 내용을 `production/stories/STORY-MOV-001.md`에 작성하고 Status를 `ready-for-dev`로 설정해도 될까요?

**사용자:**
> 네

**에이전트가 업데이트를 작성함. 스토리 상태: `ready-for-dev`.**

> **판정: READY**
> 스토리는 구현 준비가 완료되었습니다. 준비되시면 착수하세요.

---

## 2단계: 구현

### 턴 5: 사용자가 구현을 시작함

**사용자:**
> STORY-MOV-001을 구현해봅시다. 코딩 시작할 준비 됐어요.

### 턴 6: 에이전트가 스토리와 ADR을 읽음

**에이전트 (gameplay-programmer):**
> `production/stories/STORY-MOV-001.md`, `design/gdd/movement-system.md`, `docs/architecture/movement-adr-001.md` 읽는 중...
>
> **아키텍처 (ADR-001 기준):**
> - `MovementComponent.gd` — 플레이어 씬에 부착, 싱글톤 아님
> - `TerrainLayer.get_modifier(tile_position)` 헬퍼를 통한 지형 보정 조회
> - 스태미나 이벤트는 시그널로 전달 (StaminaSystem 직접 호출 아님)
>
> **제안하는 파일 구조:**
> ```
> src/gameplay/movement/
>   movement_component.gd       # CharacterBody2D 로직, 상태 머신
>   terrain_modifier_table.gd   # 상수 테이블: terrain_type -> {speed_mod, drain_mod}
> tests/unit/
>   test_movement_formulas.gd   # 속도/소모 계산을 위한 단위 테스트
> ```
>
> 이 구조로 진행해도 될까요?

**사용자:**
> 네

### 턴 7: 에이전트가 구현하고 핵심 코드를 보여줌

**에이전트:**
> `movement_component.gd`를 구현하고 있습니다. 파일을 작성하기 전에 검토하실 핵심 발췌 부분입니다:
>
> ```gdscript
> class_name MovementComponent
> extends Node
>
> signal stamina_event(type: String, amount: float)
>
> @export var base_walk_speed: float = 120.0
> @export var run_multiplier: float = 1.7
> @export var stamina_drain_walk: float = 2.0
> @export var stamina_drain_run: float = 6.0
> @export var stamina_cost_roll: float = 15.0
>
> var _is_carrying_heavy: bool = false
>
> func _physics_process(delta: float) -> void:
>     var terrain_mod := _get_terrain_modifier()
>     var effective_speed := _calculate_speed(terrain_mod)
>     # ...
> ```
>
> 모든 값이 `@export`로 되어 있습니다 — 하드코딩된 것이 없습니다. 원하시는 방향이 맞나요?

**사용자:**
> 좋아 보이네요. 작성해주세요.

### 턴 8~9: 에이전트가 파일과 테스트를 작성함

**에이전트가 작성함:**
- `src/gameplay/movement/movement_component.gd`
- `src/gameplay/movement/terrain_modifier_table.gd`
- `tests/unit/test_movement_formulas.gd`

**에이전트:**
> 파일 작성이 완료되었습니다. 가능한 린트 검사를 실행하는 중...
>
> 오류 없음. 다음을 다루는 단위 테스트 6개를 포함한 테스트 파일이 생성되었습니다:
> - 걷기 속도 공식 (지형 유형 3종)
> - 달리기 속도 공식
> - 스태미나 소모 계산
> - 구르기 스태미나 소모 (속도 0 예외 케이스 포함/미포함)
>
> 수동 테스트가 필요한 항목: 무적 프레임, 경사면 차단, 지형 연동 (실행 중인 씬이 필요함).

---

## 3단계: 스토리 완료

### 턴 10: 사용자가 수동으로 테스트하고 /story-done을 실행함

**사용자:**
> 씬에서 테스트해봤는데 — 다 잘 작동해요. /story-done production/stories/STORY-MOV-001.md

### 턴 11: 에이전트가 완료 검토를 실행함

**에이전트 (/story-done 경유):**
> 스토리, GDD, ADR을 읽는 중...
>
> **Phase 1: 스토리 위치 확인** ✅ `production/stories/STORY-MOV-001.md`
>
> **Phase 2: 승인 기준 검증**
>
> | # | 기준 | 검증 방법 | 상태 |
> |---|-----------|--------------|--------|
> | 1 | 일반 지면에서 걷기 속도가 올바름 | 자동: 공식 단위 테스트 통과 | ✅ AUTO |
> | 2 | 달리기 속도가 올바름 | 자동: 공식 단위 테스트 통과 | ✅ AUTO |
> | 3 | 스태미나 0에서 달리기 취소 | 수동: 사용자 확인 | ✅ MANUAL |
> | 4 | 구르기 무적 프레임 작동 | 수동: 사용자 확인 | ✅ MANUAL |
> | 5 | 지형 보정이 올바르게 적용됨 | 수동: 사용자 확인 | ✅ MANUAL |
> | 6 | 무거운 물체를 들면 달리기 비활성화 | 자동: 아직 테스트 불가 (인벤토리 미연동) | ⏳ DEFERRED |
> | 7 | 스태미나 시그널이 올바르게 발생 | 자동: 연동 테스트 보류 중 | ⏳ DEFERRED |
> | 8 | 하드코딩된 값 없음 | 자동: 매직 넘버 grep → 0건 발견 | ✅ AUTO |
> | 9 | 45도 초과 경사면이 이동을 차단 | 수동: 사용자 확인 | ✅ MANUAL |
>
> **Phase 3: GDD/ADR 편차**
>
> TR-ID 대비 구현을 스캔하는 중...
>
> - TR-MOV-001부터 TR-MOV-007까지: ✅ 명세대로 구현됨
> - TR-MOV-008 (무거운 물체 시그널): ⚠️ ADVISORY — 인벤토리 연동 스토리로 이연됨. 편차가 아니라 지금은 검증이 불가능할 뿐임.
>
> **Phase 4: 매니페스트 최신성 확인**
>
> 스토리의 컨트롤 매니페스트 버전 `2026-03-10`이 현재 매니페스트 `2026-03-10`과 일치함. ✅
>
> **Phase 5: 코드 리뷰 제안**
>
> 완료 처리 전에 `/code-review src/gameplay/movement/` 실행을 제안합니다. 차단 사항은 아닙니다.
>
> ---
> **완료 보고서: COMPLETE WITH NOTES**
>
> 스토리가 완료되었습니다. 두 가지 기준이 인벤토리 연동으로 이연됨 — 차단이 아니라 이연으로 기록합니다.
>
> 스토리 상태를 `Status: Complete`로 업데이트하고 완료 노트를 추가하며, `production/sprint-status.yaml`을 업데이트해도 될까요?

**사용자:**
> 네

### 턴 12: 에이전트가 스토리를 종료함

**에이전트가 작성함:**
- 스토리 `Status: Complete` + 완료 노트 (이연된 기준 명시)
- `production/sprint-status.yaml` — STORY-MOV-001을 `done`으로 설정

**에이전트:**
> STORY-MOV-001이 종료되었습니다.
>
> **이연된 기준 기록됨** (인벤토리 연동 스토리에서 자동으로 다시 표면화됩니다):
> - 무거운 물체를 들면 달리기 비활성화 (인벤토리 시그널 필요)
> - 스태미나 시그널 연동 테스트 (스태미나 시스템 필요)
>
> **스프린트의 다음 준비된 스토리:**
> - STORY-MOV-002: 스태미나 시스템 — 논리적인 다음 스토리입니다 (이제 하위 의존성이 해제됨)
> - STORY-HUD-001: 이동 HUD 표시기 — 이것도 해제되었습니다
>
> 다음에 착수할 스토리에 `/story-readiness`를 실행하세요.

---

## 이 예시가 보여주는 것

- **준비 상태 게이트가 실제 문제를 잡아냄**: `/story-readiness`가 없었다면 구르기 방향 모호함은 구현 도중 뒤늦게 결정하게 되었을 것입니다
- **ADR 상태는 강제 게이트**: `movement-adr-001.md`가 `Accepted`가 아니라 `Proposed`였다면, 스토리는 `BLOCKED`가 되고 구현이 시작되지 않았을 것입니다
- **이연된 기준**: 모든 승인 기준을 스토리 종료 시점에 검증할 수는 없습니다 — `/story-done`은 완료를 막는 대신 이연된 항목을 추적합니다
- **TR-ID 참조**: 스토리는 GDD 텍스트를 인용하는 대신 `TR-MOV-001` 같은 ID를 저장합니다 — 이후 GDD 표현이 정리될 때 잘못된 편차 플래그가 뜨는 것을 방지합니다
- **sprint-status.yaml**: 스프린트 상태의 단일 진실 공급원으로, `/story-done`이 업데이트하고 `/sprint-status`가 읽습니다
- **매니페스트 버전 확인**: 스토리의 구현 가이드가 현재 아키텍처 결정에서 벗어나지 않았는지 보장합니다
</content>
