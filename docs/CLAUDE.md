# Docs 디렉터리

이 디렉터리 안의 파일을 작성하거나 수정할 때는 다음 표준을 따른다.

## 아키텍처 결정 기록 (`docs/architecture/`)

ADR 템플릿을 사용한다: `.claude/docs/templates/architecture-decision-record.md`

**필수 섹션:** Title, Status, Context, Decision, Consequences,
ADR Dependencies, Engine Compatibility, GDD Requirements Addressed

**Status 생명주기:** `Proposed` → `Accepted` → `Superseded`
- `Accepted` 단계를 건너뛰지 말 것 — `Proposed` 상태인 ADR을 참조하는 스토리는 자동으로 차단된다
- 가이드 흐름을 통해 ADR을 만들 때는 `/architecture-decision`을 사용한다

**TR 레지스트리:** `docs/architecture/tr-registry.yaml`
- GDD 요구사항을 스토리와 연결하는 고정된 요구사항 ID(예: `TR-MOV-001`)
- 기존 ID의 번호를 재부여하지 말 것 — 새 ID만 추가한다
- `/architecture-review` Phase 8에서 업데이트된다

**컨트롤 매니페스트:** `docs/architecture/control-manifest.md`
- 레이어별 Required / Forbidden / Guardrails를 정리한 프로그래머용 규칙 시트
- 헤더에 날짜가 표시된 `Manifest Version:` 포함
- 스토리는 이 버전을 임베드하며, `/story-done`이 최신 여부를 확인한다

**검증:** ADR 세트를 완료한 후에는 `/architecture-review`를 실행한다.

## 엔진 레퍼런스 (`docs/engine-reference/`)

버전 고정된 엔진 API 스냅샷이다. **어떤 엔진 API를 사용하기 전에도 반드시 이곳을
먼저 확인할 것** — LLM의 학습 데이터는 고정된 엔진 버전보다 이전 시점까지만 반영되어 있다.

현재 엔진: `docs/engine-reference/godot/VERSION.md` 참고
