# Godot 엔진 — 버전 레퍼런스

| 항목 | 값 |
|-------|-------|
| **엔진 버전** | Godot 4.6 |
| **출시일** | 2026년 1월 |
| **프로젝트 고정일** | 2026-02-12 |
| **문서 최종 검증일** | 2026-02-12 |
| **LLM 지식 컷오프** | 2025년 5월 |

## 지식 공백 경고

LLM의 학습 데이터는 아마 Godot 4.3 정도까지만 다루고 있을 것이다. 4.4, 4.5,
4.6 버전은 모델이 알지 못하는 중대한 변경 사항들을 도입했다.
Godot API 호출을 제안하기 전에는 항상 이 디렉터리를 먼저 대조 확인할 것.

## 컷오프 이후 버전 타임라인

| 버전 | 출시 | 위험 수준 | 핵심 테마 |
|---------|---------|------------|-----------|
| 4.4 | 2025년 중반경 | MEDIUM | Jolt 물리 옵션, FileAccess 반환 타입, 셰이더 텍스처 타입 변경 |
| 4.5 | 2025년 후반경 | HIGH | 접근성(AccessKit), 가변 인자, @abstract, 셰이더 베이커, SMAA |
| 4.6 | 2026년 1월 | HIGH | Jolt 기본화, glow 재구성, Windows에서 D3D12 기본화, IK 복원 |

## 검증된 출처

- 공식 문서: https://docs.godotengine.org/en/stable/
- 4.5→4.6 마이그레이션: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 마이그레이션: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- 체인지로그: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- 릴리스 노트: https://godotengine.org/releases/4.6/
