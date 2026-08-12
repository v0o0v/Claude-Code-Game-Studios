# Unreal Engine 5.7 — Gameplay Camera System

**최종 확인일:** 2026-02-13
**상태:** ⚠️ 실험적(UE 5.5에서 도입)
**플러그인:** `GameplayCameras` (기본 내장, Plugins에서 활성화)

---

## 개요

**Gameplay Camera System**은 UE 5.5에서 도입된 모듈형 카메라 관리 프레임워크다.
전통적인 카메라 구성 방식을 대체하며, 카메라 모드, 블렌딩, 상황 인지형 카메라
동작을 처리하는 유연한 노드 기반 시스템이다.

**Gameplay Cameras를 사용해야 하는 경우:**
- 동적 카메라 동작(3인칭, 조준, 차량, 시네마틱)
- 상황 인지형 카메라 전환(전투, 탐험, 대화)
- 모드 간 부드러운 카메라 블렌딩
- 프로시저럴 카메라 모션(카메라 셰이크, 랙, 오프셋)

**⚠️ 주의:** 이 플러그인은 UE 5.5~5.7에서 실험적 단계다. 향후 버전에서 API 변경이 있을 수 있다.

---

## 핵심 개념

### 1. **Camera Rig**
- 카메라 구성(위치, 회전, FOV 등)을 정의
- 모듈형 노드 그래프(Material Editor와 유사)

### 2. **Camera Director**
- 현재 활성화된 카메라 리그를 관리
- 카메라 리그 간 블렌딩을 처리

### 3. **Camera Nodes**
- 카메라 동작을 구성하는 빌딩 블록:
  - **Position Nodes**: 오빗(Orbit), 팔로우(Follow), 고정 위치(Fixed Position)
  - **Rotation Nodes**: Look At, 액터 회전 매칭
  - **Modifiers**: 카메라 셰이크, 랙, 오프셋

---

## 설정

### 1. 플러그인 활성화

`Edit > Plugins > Gameplay Cameras > Enabled > Restart`

### 2. Camera Component 추가

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

UCLASS()
class AMyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AMyCharacter() {
        // Create camera component
        CameraComponent = CreateDefaultSubobject<UGameplayCameraComponent>(TEXT("GameplayCamera"));
        CameraComponent->SetupAttachment(RootComponent);
    }

protected:
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
    TObjectPtr<UGameplayCameraComponent> CameraComponent;
};
```

---

## Camera Rig 생성

### 1. Camera Rig 애셋 생성

1. Content Browser > Gameplay > Gameplay Camera Rig
2. Camera Rig 에디터(노드 기반 그래프)를 연다

### 2. Camera Rig 구성(예시: 3인칭)

**노드 구성:**
```
Actor Position (Character)
  ↓
Orbit Node (Orbit around character)
  ↓
Offset Node (Shoulder offset)
  ↓
Look At Node (Look at character)
  ↓
Camera Output
```

---

## Camera Nodes

### Position Nodes

#### Orbit Node(3인칭)
- 대상 액터를 중심으로 궤도 회전
- 구성 항목:
  - **Orbit Distance**: 대상과의 거리(예: 300 유닛)
  - **Pitch Range**: 최소/최대 피치 각도
  - **Yaw Range**: 최소/최대 요 각도

#### Follow Node(부드러운 추적)
- 랙(lag)을 적용해 대상을 따라감
- 구성 항목:
  - **Lag Speed**: 카메라가 대상을 따라잡는 속도
  - **Offset**: 대상으로부터의 고정 오프셋

#### Fixed Position Node
- 월드 공간상의 고정된 카메라 위치

---

### Rotation Nodes

#### Look At Node
- 카메라를 대상 쪽으로 향하게 함
- 구성 항목:
  - **Target**: 바라볼 액터 또는 컴포넌트
  - **Offset**: Look-at 오프셋(예: 발이 아닌 머리를 조준)

#### Match Actor Rotation
- 대상 액터의 회전값을 그대로 따름
- 1인칭 또는 차량 카메라에 유용

---

### Modifier Nodes

#### Camera Shake
- 프로시저럴 셰이크를 추가(예: 발소리, 폭발)
- 구성 항목:
  - **Shake Pattern**: 펄린 노이즈, 사인파, 커스텀
  - **Amplitude**: 셰이크 강도

#### Camera Lag
- 카메라 움직임을 부드럽게 감쇠
- 구성 항목:
  - **Lag Speed**: 감쇠 계수(0 = 즉시 반응, 값이 클수록 랙이 커짐)

#### Offset Node
- 계산된 위치로부터의 고정 오프셋
- 숄더 카메라 오프셋에 유용

---

## Camera Director(리그 간 전환)

### Camera Rig 할당

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

void AMyCharacter::SetCameraMode(UGameplayCameraRig* NewRig) {
    if (CameraComponent) {
        CameraComponent->SetCameraRig(NewRig);
    }
}
```

### Camera Rig 간 블렌딩

```cpp
// Blend to aiming camera over 0.5 seconds
CameraComponent->BlendToCameraRig(AimingCameraRig, 0.5f);
```

---

## 예시: 3인칭 + 조준

### 1. 두 개의 Camera Rig 생성

**3인칭 리그:**
```
Actor Position → Orbit (distance: 300) → Look At → Output
```

**조준 리그:**
```
Actor Position → Orbit (distance: 150) → Offset (shoulder) → Look At → Output
```

### 2. 조준 시 전환

```cpp
UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> ThirdPersonRig;

UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> AimingRig;

void StartAiming() {
    CameraComponent->BlendToCameraRig(AimingRig, 0.3f); // Blend over 0.3s
}

void StopAiming() {
    CameraComponent->BlendToCameraRig(ThirdPersonRig, 0.3f);
}
```

---

## 일반적인 패턴

### 오버 더 숄더 카메라

```
Actor Position
  ↓
Orbit Node (distance: 250, yaw offset: 30°)
  ↓
Offset Node (X: 0, Y: 50, Z: 50) // Shoulder offset
  ↓
Look At Node (target: Character head)
  ↓
Output
```

---

### 차량 카메라

```
Vehicle Position
  ↓
Follow Node (lag: 0.2)
  ↓
Offset Node (behind vehicle: X: -400, Z: 150)
  ↓
Look At Node (target: Vehicle)
  ↓
Output
```

---

### 1인칭 카메라

```
Character Head Socket
  ↓
Match Actor Rotation
  ↓
Output
```

---

## 카메라 셰이크

### 카메라 셰이크 트리거

```cpp
#include "GameplayCameras/Public/GameplayCameraShake.h"

void TriggerExplosionShake() {
    if (APlayerController* PC = GetWorld()->GetFirstPlayerController()) {
        if (UGameplayCameraComponent* CameraComp = PC->FindComponentByClass<UGameplayCameraComponent>()) {
            CameraComp->PlayCameraShake(ExplosionShakeClass, 1.0f);
        }
    }
}
```

---

## 성능 팁

- 카메라 셰이크 발생 빈도를 제한한다(매 프레임 트리거하지 않는다)
- 카메라 랙은 절제해서 사용한다(랙 값이 크면 비용이 많이 든다)
- 카메라 리그 참조를 캐싱한다(매 프레임 검색하지 않는다)

---

## 디버깅

### 카메라 디버그 시각화

```cpp
// Console commands:
// GameplayCameras.Debug 1 - Show active camera rig info
// showdebug camera - Show camera debug info
```

---

## 레거시 카메라에서 마이그레이션

### 기존 Spring Arm + Camera Component

```cpp
// ❌ OLD: Spring Arm Component
USpringArmComponent* SpringArm;
UCameraComponent* Camera;

// ✅ NEW: Gameplay Camera Component
UGameplayCameraComponent* CameraComponent;
// Build orbit + look-at rig in Camera Rig asset
```

---

## 제약 사항(실험적 상태)

- **API 불안정성**: UE 5.8 이상에서 호환성이 깨지는 변경이 있을 수 있음
- **제한적인 문서**: 공식 문서가 아직 발전 중
- **Blueprint 지원**: 주로 C++ 중심(Blueprint 지원은 개선 중)
- **프로덕션 리스크**: 출시 전 충분한 테스트 필요

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/
- UE 5.5+ 릴리스 노트
- **참고:** 이 시스템은 실험적 단계다. API 변경 사항은 항상 최신 공식 문서를 확인할 것.
