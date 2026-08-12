# Unreal Engine 5.7 — 선택적 플러그인 & 시스템

**최종 확인일:** 2026-02-13

이 문서는 Unreal Engine 5.7에서 사용 가능한 **선택적 플러그인 및 시스템**을 정리한다.
이들은 코어 엔진의 일부가 아니지만 특정 게임 장르에서 흔히 사용된다.

---

## 이 가이드 사용법

**✅ 상세 문서 있음** - 포괄적인 가이드는 `plugins/` 디렉터리를 참고
**🟡 간략 개요만 제공** - 공식 문서 링크 참고, 상세 내용은 WebSearch 사용
**⚠️ 실험적 기능** - 향후 버전에서 주요(Breaking) 변경이 있을 수 있음
**📦 플러그인 필요** - `Edit > Plugins`에서 활성화해야 함

---

## 프로덕션 준비가 완료된 시스템(상세 문서 제공)

### ✅ Gameplay Ability System(GAS)
- **목적:** 모듈형 어빌리티 시스템(어빌리티, 속성, 이펙트, 쿨다운, 비용)
- **사용 시점:** RPG, MOBA, 어빌리티가 있는 슈터, 어빌리티 기반 게임플레이 전반
- **지식 공백:** GAS는 UE4부터 안정적이었으며, UE5의 개선 사항은 학습 데이터 기준일 이후
- **상태:** 프로덕션 준비 완료
- **플러그인:** `GameplayAbilities`(내장, Plugins에서 활성화)
- **상세 문서:** [plugins/gameplay-ability-system.md](plugins/gameplay-ability-system.md)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/gameplay-ability-system-for-unreal-engine/

---

### ✅ CommonUI
- **목적:** 크로스플랫폼 UI 프레임워크(게임패드/마우스/터치 입력 자동 라우팅)
- **사용 시점:** 멀티플랫폼 게임(콘솔 + PC), 입력 방식에 구애받지 않는 UI
- **지식 공백:** UE5 이상에서 프로덕션 준비 완료, 학습 데이터 기준일 이후의 주요 개선
- **상태:** 프로덕션 준비 완료
- **플러그인:** `CommonUI`(내장, Plugins에서 활성화)
- **상세 문서:** [plugins/common-ui.md](plugins/common-ui.md)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/

---

### ✅ Gameplay Camera System
- **목적:** 모듈형 카메라 관리(카메라 모드, 블렌딩, 컨텍스트 인식 카메라)
- **사용 시점:** 다이내믹한 카메라 동작이 필요한 게임(3인칭, 조준, 차량)
- **지식 공백:** UE 5.5에서 신규 도입, 완전히 학습 데이터 기준일 이후
- **상태:** ⚠️ 실험적(UE 5.5-5.7)
- **플러그인:** `GameplayCameras`(내장, Plugins에서 활성화)
- **상세 문서:** [plugins/gameplay-camera-system.md](plugins/gameplay-camera-system.md)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/

---

### ✅ PCG(절차적 콘텐츠 생성)
- **목적:** 노드 기반 절차적 월드 생성(식생, 소품, 지형 디테일)
- **사용 시점:** 오픈 월드, 절차적 레벨, 대규모 환경 배치
- **지식 공백:** UE 5.0-5.6에서는 실험적, 5.7에서 프로덕션 준비 완료
- **상태:** 프로덕션 준비 완료(UE 5.7 기준)
- **플러그인:** `PCG`(내장, Plugins에서 활성화)
- **상세 문서:** [plugins/pcg.md](plugins/pcg.md)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/

---

## 그 외 프로덕션 준비가 완료된 플러그인(간략 개요)

### 🟡 Mass Entity
- **목적:** 대규모 AI/군중을 위한 고성능 ECS(10,000개 이상의 엔티티)
- **사용 시점:** RTS, 도시 시뮬레이터, 대규모 군중, 대규모 AI
- **상태:** 프로덕션 준비 완료(UE 5.1 이상)
- **플러그인:** `MassEntity`, `MassGameplay`, `MassCrowd`
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/mass-entity-in-unreal-engine/

---

### 🟡 Niagara Fluids
- **목적:** GPU 유체 시뮬레이션(연기, 불, 액체)
- **사용 시점:** 사실적인 화염/연기 효과, 물 시뮬레이션
- **상태:** 실험적 → 프로덕션 준비 완료(UE 5.4 이상)
- **플러그인:** `NiagaraFluids`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/niagara-fluids-in-unreal-engine/

---

### 🟡 Water 플러그인
- **목적:** 부력을 포함한 바다, 강, 호수 렌더링
- **사용 시점:** 수역이 있는 게임, 보트, 수영
- **상태:** 프로덕션 준비 완료(UE 5.0 이상)
- **플러그인:** `Water`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/water-system-in-unreal-engine/

---

### 🟡 Landmass 플러그인
- **목적:** 지형 조각 및 랜드스케이프 편집
- **사용 시점:** 대규모 지형 수정, 절차적 랜드스케이프
- **상태:** 프로덕션 준비 완료
- **플러그인:** `Landmass`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/landmass-plugin-in-unreal-engine/

---

### 🟡 Chaos Destruction
- **목적:** 실시간 파괴 및 붕괴
- **사용 시점:** 파괴 가능한 환경(벽, 건물, 오브젝트)
- **상태:** 프로덕션 준비 완료(UE 5.0 이상)
- **플러그인:** `ChaosDestruction`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/destruction-in-unreal-engine/

---

### 🟡 Chaos Vehicle
- **목적:** 고급 차량 물리(바퀴 달린 차량, 서스펜션)
- **사용 시점:** 레이싱 게임, 차량 비중이 높은 게임플레이
- **상태:** 프로덕션 준비 완료(PhysX Vehicles 대체)
- **플러그인:** `ChaosVehicles`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/chaos-vehicles-overview-in-unreal-engine/

---

### 🟡 Geometry Scripting
- **목적:** 런타임 절차적 메시 생성 및 편집
- **사용 시점:** 다이내믹 메시 생성, 절차적 모델링
- **상태:** 프로덕션 준비 완료(UE 5.1 이상)
- **플러그인:** `GeometryScripting`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/geometry-scripting-in-unreal-engine/

---

### 🟡 Motion Design 툴
- **목적:** 모션 그래픽, 절차적 애니메이션, 키프레임 애니메이션
- **사용 시점:** UI 애니메이션, 절차적 모션, 키프레임 시퀀스
- **상태:** 실험적 → 프로덕션 준비 완료(UE 5.4 이상)
- **플러그인:** `MotionDesign`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/motion-design-mode-in-unreal-engine/

---

## 실험적 플러그인(주의해서 사용할 것)

### ⚠️ AI 어시스턴트(UE 5.7 이상)
- **목적:** 에디터 내 AI 가이드 및 도움말
- **상태:** 실험적
- **플러그인:** UE 5.7 설정에서 활성화
- **공식 문서:** UE 5.7 릴리스에서 발표됨

---

### ⚠️ OpenXR(VR/AR)
- **목적:** 크로스플랫폼 VR/AR 지원
- **사용 시점:** VR/AR 게임
- **상태:** VR은 프로덕션 준비 완료, AR은 실험적
- **플러그인:** `OpenXR`(내장)
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/openxr-in-unreal-engine/

---

### ⚠️ Online Subsystem(EOS, Steam 등)
- **목적:** 플랫폼에 종속되지 않는 온라인 서비스(매치메이킹, 친구, 업적)
- **사용 시점:** 온라인 기능이 있는 멀티플레이어 게임
- **상태:** 프로덕션 준비 완료
- **플러그인:** `OnlineSubsystem`, `OnlineSubsystemEOS`, `OnlineSubsystemSteam`
- **공식 문서:** https://docs.unrealengine.com/5.7/en-US/online-subsystem-in-unreal-engine/

---

## 지원 중단된 플러그인(신규 프로젝트에서는 피할 것)

### ❌ PhysX Vehicles
- **지원 중단:** 대신 Chaos Vehicles를 사용할 것
- **상태:** 레거시, 권장하지 않음

---

### ❌ 구 Replication Graph
- **지원 중단:** Iris로 대체됨(UE 5.1 이상)
- **상태:** 최신 네트워킹에는 Iris를 사용할 것

---

## 온디맨드 WebSearch 전략

위 목록에 없는 플러그인에 대해서는 사용자가 질문할 때 다음 방식을 사용한다.

1. 최신 문서를 찾기 위해 **WebSearch** 사용: `"Unreal Engine 5.7 [plugin name]"`
2. 다음 사항을 확인한다.
   - 학습 데이터 기준일(2025년 5월) 이후에 나온 것인지
   - 실험적인지 프로덕션 준비가 완료되었는지
   - UE 5.7에서 여전히 지원되는지
3. 필요하다면 향후 참고를 위해 조사 결과를 `plugins/[plugin-name].md`에 캐싱해 둘 것

---

## 빠른 의사결정 가이드

**어빌리티/스킬/버프가 필요하다** → **Gameplay Ability System(GAS)**
**크로스플랫폼 UI(콘솔 + PC)가 필요하다** → **CommonUI**
**다이내믹 카메라가 필요하다** → **Gameplay Camera System**
**절차적 월드가 필요하다** → **PCG**
**대규모 군중(수천 개의 AI)이 필요하다** → **Mass Entity**
**파괴 가능한 환경이 필요하다** → **Chaos Destruction**
**차량이 필요하다** → **Chaos Vehicles**
**물/바다가 필요하다** → **Water 플러그인**
**VR/AR이 필요하다** → **OpenXR**

---

**최종 업데이트:** 2026-02-13
**엔진 버전:** Unreal Engine 5.7
**LLM 학습 데이터 기준일:** 2025년 5월
