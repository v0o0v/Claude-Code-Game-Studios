# Unreal Engine — 버전 레퍼런스

| 항목 | 값 |
|-------|-------|
| **엔진 버전** | Unreal Engine 5.7 |
| **출시일** | 2025년 11월 |
| **프로젝트 고정일** | 2026-02-13 |
| **문서 최종 확인일** | 2026-02-13 |
| **LLM 학습 데이터 기준일** | 2025년 5월 |

## 지식 공백 경고

LLM의 학습 데이터는 대체로 Unreal Engine 5.3까지만 다루고 있다. 5.4, 5.5,
5.6, 5.7 버전에는 모델이 알지 못하는 중대한 변경 사항이 도입되었다.
Unreal API를 제안하기 전에는 항상 이 디렉터리를 먼저 대조 확인할 것.

## 학습 데이터 기준일 이후 버전 타임라인

| 버전 | 출시 시기 | 위험도 | 핵심 테마 |
|---------|---------|------------|-----------|
| 5.4 | 2025년 중반 경 | HIGH | Motion Design 툴, 애니메이션 개선, PCG 강화 |
| 5.5 | 2025년 9월 경 | HIGH | Megalights(수백만 개의 광원), 애니메이션 오서링, MegaCity 데모 |
| 5.6 | 2025년 10월 경 | MEDIUM | 성능 최적화, 버그 수정 |
| 5.7 | 2025년 11월 | HIGH | PCG 프로덕션 준비 완료, Substrate 프로덕션 준비 완료, AI 어시스턴트 |

## UE 5.3에서 UE 5.7로의 주요 변경 사항

### 주요(Breaking) 변경 사항
- **Substrate 머티리얼 시스템**: 새로운 머티리얼 프레임워크(레거시 머티리얼 대체)
- **PCG(절차적 콘텐츠 생성)**: 프로덕션 준비 완료, 대규모 API 변경
- **Megalights**: 새로운 조명 시스템(수백만 개의 다이내믹 광원)
- **애니메이션 오서링**: 새로운 리깅 및 애니메이션 툴
- **AI 어시스턴트**: 에디터 내 AI 가이드(실험적 기능)

### 신규 기능(학습 데이터 기준일 이후)
- **Megalights**: 대규모 다이내믹 조명(수백만 개의 광원)
- **Substrate 머티리얼**: 프로덕션 준비가 완료된 모듈형 머티리얼 시스템
- **PCG 프레임워크**: 절차적 월드 생성(5.7에서 프로덕션 준비 완료)
- **가상 프로덕션 강화**: MetaHuman 통합, 더 심화된 VP 워크플로
- **애니메이션 개선**: 향상된 리깅, 블렌딩, 절차적 애니메이션
- **AI 어시스턴트**: 에디터 내 AI 도움말(실험적 기능)

### 지원 중단(Deprecated)된 시스템
- **레거시 머티리얼 시스템**: 신규 프로젝트에서는 Substrate로 마이그레이션할 것
- **구 PCG API**: 새로운 프로덕션 준비 완료 PCG API를 사용할 것(5.7 이상)

## 확인된 출처

- 공식 문서: https://docs.unrealengine.com/5.7/
- UE 5.7 릴리스 노트: https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- 5.7의 새로운 기능: https://dev.epicgames.com/documentation/en-us/unreal-engine/whats-new
- UE 5.7 공지: https://www.unrealengine.com/en-US/news/unreal-engine-5-7-is-now-available
- UE 5.5 블로그: https://www.unrealengine.com/en-US/blog/unreal-engine-5-5-is-now-available
- 마이그레이션 가이드: https://docs.unrealengine.com/5.7/en-US/upgrading-projects/
