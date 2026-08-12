# Unity 6.3 LTS — 선택적 패키지 및 시스템

**최종 확인일:** 2026-02-13

이 문서는 Unity 6.3 LTS에서 사용 가능한 **선택적 패키지 및 시스템**을 정리한다.
이들은 코어 엔진의 일부가 아니지만, 특정 게임 유형에서 흔히 사용된다.

---

## 이 가이드 사용법

**✅ 상세 문서 제공** - 포괄적인 가이드는 `plugins/` 디렉터리를 참고
**🟡 간략한 개요만 제공** - 공식 문서로 링크되며, 상세 내용은 WebSearch를 사용할 것
**⚠️ 프리뷰(Preview)** - 향후 버전에서 파괴적 변경이 있을 수 있음
**📦 패키지 필요** - Package Manager를 통해 설치

---

## 프로덕션 준비 완료 패키지(상세 문서 제공)

### ✅ Cinemachine
- **용도:** 가상 카메라 시스템(동적 카메라, 컷신, 카메라 블렌딩)
- **사용 시점:** 3인칭 게임, 시네마틱, 복잡한 카메라 동작
- **지식 공백:** Cinemachine 3.0+(Unity 6)는 2.x 대비 대규모 API 변경이 있음
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.cinemachine`(Package Manager)
- **상세 문서:** [plugins/cinemachine.md](plugins/cinemachine.md)
- **공식:** https://docs.unity3d.com/Packages/com.unity.cinemachine@3.0/manual/index.html

---

### ✅ Addressables
- **용도:** 고급 에셋 관리(비동기 로딩, 원격 콘텐츠, 메모리 제어)
- **사용 시점:** 대규모 프로젝트, DLC, 원격 콘텐츠 전달
- **지식 공백:** Unity 6 개선사항, 향상된 성능
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.addressables`(Package Manager)
- **상세 문서:** [plugins/addressables.md](plugins/addressables.md)
- **공식:** https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html

---

### ✅ DOTS / Entities(ECS)
- **용도:** Data-Oriented Technology Stack(대규모 스케일을 위한 고성능 ECS)
- **사용 시점:** 수천 개의 엔티티가 있는 게임, RTS, 시뮬레이션
- **지식 공백:** Entities 1.3+(Unity 6)는 프로덕션 준비 완료 상태이며, 0.x 대비 대규모 재작성됨
- **상태:** 프로덕션 준비 완료(Unity 6.3 LTS 기준)
- **패키지:** `com.unity.entities`(Package Manager)
- **상세 문서:** [plugins/dots-entities.md](plugins/dots-entities.md)
- **공식:** https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html

---

## 기타 프로덕션 준비 완료 패키지(간략한 개요)

### 🟡 Input System(이미 다룸)
- **용도:** 현대적인 입력 처리(리바인딩 가능, 크로스플랫폼)
- **상태:** 프로덕션 준비 완료(Unity 6에서 기본값)
- **패키지:** `com.unity.inputsystem`
- **문서:** [modules/input.md](../modules/input.md) 참고
- **공식:** https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html

---

### 🟡 UI Toolkit(이미 다룸)
- **용도:** 현대적인 런타임 UI(HTML/CSS와 유사, 고성능)
- **상태:** 프로덕션 준비 완료(Unity 6)
- **패키지:** 내장(Built-in)
- **문서:** [modules/ui.md](../modules/ui.md) 참고
- **공식:** https://docs.unity3d.com/Packages/com.unity.ui@2.0/manual/index.html

---

### 🟡 Visual Effect Graph(VFX Graph)
- **용도:** GPU 가속 파티클 시스템(수백만 개의 파티클)
- **사용 시점:** 대규모 VFX, 불, 연기, 마법, 폭발
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.visualeffectgraph`(URP/HDRP 전용)
- **공식:** https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/index.html

---

### 🟡 Shader Graph
- **용도:** 비주얼 셰이더 에디터(노드 기반 셰이더 제작)
- **사용 시점:** HLSL 코딩 없이 커스텀 셰이더를 만들 때
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.shadergraph`(URP/HDRP)
- **공식:** https://docs.unity3d.com/Packages/com.unity.shadergraph@17.0/manual/index.html

---

### 🟡 Timeline
- **용도:** 시네마틱 시퀀싱(컷신, 스크립트 이벤트)
- **사용 시점:** 스토리 중심 게임, 시네마틱, 스크립트 시퀀스
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.timeline`(내장)
- **공식:** https://docs.unity3d.com/Packages/com.unity.timeline@1.8/manual/index.html

---

### 🟡 Animation Rigging
- **용도:** 런타임 IK, 절차적 애니메이션
- **사용 시점:** 발 IK, 조준 오프셋, 절차적 팔다리 배치
- **상태:** 프로덕션 준비 완료(Unity 6)
- **패키지:** `com.unity.animation.rigging`
- **공식:** https://docs.unity3d.com/Packages/com.unity.animation.rigging@1.3/manual/index.html

---

### 🟡 ProBuilder
- **용도:** 에디터 내 3D 모델링(레벨 프로토타이핑, 그레이박싱)
- **사용 시점:** 빠른 프로토타이핑, 레벨 블록아웃
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.probuilder`
- **공식:** https://docs.unity3d.com/Packages/com.unity.probuilder@6.0/manual/index.html

---

### 🟡 Netcode for GameObjects
- **용도:** Unity 공식 멀티플레이어 네트워킹
- **사용 시점:** 멀티플레이어 게임(클라이언트-서버 아키텍처)
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.netcode.gameobjects`
- **공식:** https://docs-multiplayer.unity3d.com/netcode/current/about/

---

### 🟡 Burst Compiler
- **용도:** C# Jobs를 위한 LLVM 기반 컴파일러(대폭적인 성능 향상)
- **사용 시점:** 성능이 중요한 코드, DOTS, Jobs 시스템
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.burst`(DOTS와 함께 자동 설치됨)
- **공식:** https://docs.unity3d.com/Packages/com.unity.burst@1.8/manual/index.html

---

### 🟡 Jobs System
- **용도:** 멀티스레드 잡 스케줄링(CPU 병렬 처리)
- **사용 시점:** 성능 최적화, 병렬 처리
- **상태:** 프로덕션 준비 완료
- **패키지:** 내장(Built-in)
- **공식:** https://docs.unity3d.com/Manual/JobSystem.html

---

### 🟡 Mathematics
- **용도:** SIMD 수학 라이브러리(Burst에 최적화됨)
- **사용 시점:** DOTS, 고성능 수학 연산
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.mathematics`
- **공식:** https://docs.unity3d.com/Packages/com.unity.mathematics@1.3/manual/index.html

---

### 🟡 ML-Agents(머신러닝)
- **용도:** 강화학습으로 AI 학습시키기
- **사용 시점:** 고급 AI 트레이닝, 절차적 행동
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.ml-agents`
- **공식:** https://github.com/Unity-Technologies/ml-agents

---

### 🟡 Recorder
- **용도:** 게임플레이 영상, 스크린샷, 애니메이션 클립 캡처
- **사용 시점:** 트레일러, 리플레이, 디버그 녹화
- **상태:** 프로덕션 준비 완료
- **패키지:** `com.unity.recorder`
- **공식:** https://docs.unity3d.com/Packages/com.unity.recorder@5.0/manual/index.html

---

## 프리뷰/실험적 패키지(주의해서 사용)

### ⚠️ Splines
- **용도:** 런타임 스플라인 생성 및 편집
- **사용 시점:** 도로, 경로, 절차적 콘텐츠
- **상태:** 프로덕션 준비 완료(Unity 6)
- **패키지:** `com.unity.splines`
- **공식:** https://docs.unity3d.com/Packages/com.unity.splines@2.6/manual/index.html

---

### ⚠️ Muse(AI 어시스턴트)
- **용도:** AI 기반 에셋 제작(텍스처, 스프라이트, 애니메이션)
- **상태:** 프리뷰(Unity 6)
- **패키지:** `com.unity.muse.*`
- **공식:** https://unity.com/products/muse

---

### ⚠️ Sentis(신경망 추론)
- **용도:** Unity 안에서 신경망 실행(AI 추론)
- **상태:** 프리뷰
- **패키지:** `com.unity.sentis`
- **공식:** https://docs.unity3d.com/Packages/com.unity.sentis@2.0/manual/index.html

---

## 폐기 예정 패키지(신규 프로젝트에는 피할 것)

### ❌ UGUI(Canvas UI)
- **폐기 예정:** 여전히 지원되지만, UI Toolkit이 권장됨
- **대신 사용:** UI Toolkit

---

### ❌ 레거시 파티클 시스템
- **폐기 예정:** Visual Effect Graph(VFX Graph)를 사용할 것
- **대신 사용:** VFX Graph

---

### ❌ 레거시 애니메이션
- **폐기 예정:** Animator(Mecanim)를 사용할 것
- **대신 사용:** Animator Controller

---

## 온디맨드 WebSearch 전략

위에 목록화되지 않은 패키지의 경우, 사용자가 물어볼 때 다음 절차를 사용할 것:

1. 최신 문서를 위해 **WebSearch**: `"Unity 6.3 [package name]"`
2. 다음 사항을 확인할 것:
   - 컷오프 이후 등장한 것인지(2025년 5월 학습 데이터 이후)
   - 프리뷰인지 프로덕션 준비 완료인지
   - Unity 6.3 LTS에서 여전히 지원되는지
3. 필요 시 향후 참고를 위해 `plugins/[package-name].md`에 조사 내용을 캐싱할 것

---

## 빠른 의사결정 가이드

**가상 카메라가 필요하다** → **Cinemachine**
**비동기 에셋 로딩/DLC가 필요하다** → **Addressables**
**수천 개의 엔티티가 필요하다(RTS, 시뮬레이션)** → **DOTS/Entities**
**현대적인 입력이 필요하다** → **Input System**(modules/input.md 참고)
**GPU 파티클이 필요하다** → **Visual Effect Graph**
**비주얼 셰이더가 필요하다** → **Shader Graph**
**시네마틱이 필요하다** → **Timeline**
**런타임 IK가 필요하다** → **Animation Rigging**
**레벨 프로토타이핑이 필요하다** → **ProBuilder**
**멀티플레이어가 필요하다** → **Netcode for GameObjects**

---

**최종 업데이트:** 2026-02-13
**엔진 버전:** Unity 6.3 LTS
**LLM 지식 컷오프:** 2025년 5월
