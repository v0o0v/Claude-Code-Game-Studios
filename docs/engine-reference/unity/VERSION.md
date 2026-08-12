# Unity 엔진 — 버전 레퍼런스

| 항목 | 값 |
|-------|-------|
| **엔진 버전** | Unity 6.3 LTS |
| **출시일** | 2025년 12월 |
| **프로젝트 고정일** | 2026-02-13 |
| **문서 최종 확인일** | 2026-02-13 |
| **LLM 지식 컷오프** | 2025년 5월 |

## 지식 공백 경고

LLM의 학습 데이터는 대체로 Unity 2022 LTS(2022.3) 수준까지만 다룬다. Unity 6 릴리스
시리즈 전체(구 Unity 2023 테크 스트림)는 모델이 알지 못하는 중대한 변경을 다수
도입했다. Unity API를 제안하기 전에는 항상 이 디렉터리를 먼저 대조 확인할 것.

## 컷오프 이후 버전 타임라인

| 버전 | 출시 | 위험도 | 핵심 테마 |
|---------|---------|------------|-----------|
| 6.0 | 2024년 10월 | 높음 | Unity 6 리브랜딩, 신규 렌더링 기능, Entities 1.3, DOTS 개선 |
| 6.1 | 2024년 11월 | 중간 | 버그 수정, 안정성 개선 |
| 6.2 | 2024년 12월 | 중간 | 성능 최적화, 새 입력 시스템 개선 |
| 6.3 LTS | 2025년 12월 | 높음 | 6.0 이후 첫 LTS, 프로덕션 준비된 DOTS, 강화된 그래픽 기능 |

## 2022 LTS에서 Unity 6.3 LTS로의 주요 변경사항

### 파괴적 변경사항(Breaking Changes)
- **Entities/DOTS**: Entities 1.0+에서 API 대규모 개편, ECS 패턴 전면 재설계
- **입력 시스템**: 레거시 Input Manager 폐기 예정(deprecated), 새 입력 시스템이 기본값
- **렌더링**: URP/HDRP 대폭 업그레이드, SRP 배처(SRP Batcher) 개선
- **Addressables**: 에셋 관리 워크플로 변경
- **스크립팅**: C# 9 지원, 새로운 API 패턴

### 신규 기능(컷오프 이후)
- **DOTS**: 프로덕션 준비된 Entity Component System(Entities 1.3+)
- **그래픽**: 강화된 URP/HDRP 파이프라인, GPU 상주 드로어(GPU Resident Drawer)
- **멀티플레이어**: Netcode for GameObjects 개선
- **UI Toolkit**: 런타임 UI용으로 프로덕션 준비 완료(신규 프로젝트에서 UGUI 대체)
- **비동기 에셋 로딩**: Addressables 성능 개선
- **웹**: WebGPU 지원

### 폐기 예정 시스템
- **레거시 Input Manager**: 새 입력 시스템 패키지 사용
- **레거시 파티클 시스템**: Visual Effect Graph 사용
- **UGUI**: 여전히 지원되지만, 신규 프로젝트에는 UI Toolkit 권장
- **구 ECS(GameObjectEntity)**: 최신 DOTS/Entities로 대체됨

## 검증된 출처

- 공식 문서: https://docs.unity3d.com/6000.0/Documentation/Manual/index.html
- Unity 6 릴리스: https://unity.com/releases/unity-6
- Unity 6.3 LTS 발표: https://unity.com/blog/unity-6-3-lts-is-now-available
- 마이그레이션 가이드: https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- Unity 6 지원: https://unity.com/releases/unity-6/support
- C# API 레퍼런스: https://docs.unity3d.com/6000.0/Documentation/ScriptReference/index.html
