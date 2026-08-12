# Unreal Engine 5.7 — 애니메이션 모듈 레퍼런스

**최종 검증일:** 2026-02-13
**지식 공백:** UE 5.7 애니메이션 저작 개선 사항, Control Rig 2.0

---

## 개요

UE 5.7 애니메이션 시스템:
- **Animation Blueprint**: 스테이트 머신 기반 애니메이션 로직
- **Control Rig**: 런타임 프로시저럴 애니메이션(UE5에서 프로덕션 준비 완료)
- **IK Rig + Retargeter**: 최신 리타겟팅 시스템
- **Sequencer**: 시네마틱 애니메이션

---

## Animation Blueprint

### Animation Blueprint 생성

1. Content Browser > 우클릭 > Animation > Animation Blueprint
2. 부모 클래스 선택: `AnimInstance`
3. 스켈레톤 선택

### 애니메이션 스테이트 머신

```cpp
// In Animation Blueprint Event Graph:
// - State Machine drives animation states (Idle, Walk, Run, Jump)
// - Blend Spaces for directional movement

// Access in C++:
UAnimInstance* AnimInstance = Mesh->GetAnimInstance();
AnimInstance->Montage_Play(AttackMontage);
```

---

## Animation Montage 재생

### Animation Montage

```cpp
// Play montage
UAnimInstance* AnimInstance = GetMesh()->GetAnimInstance();
AnimInstance->Montage_Play(AttackMontage, 1.0f);

// Stop montage
AnimInstance->Montage_Stop(0.2f, AttackMontage);

// Check if montage is playing
bool bIsPlaying = AnimInstance->Montage_IsPlaying(AttackMontage);
```

### Montage Notify 이벤트

```cpp
// Add notify event in Animation Montage (right-click timeline > Add Notify > New Notify)
// Implement in C++:

UCLASS()
class UMyAnimInstance : public UAnimInstance {
    GENERATED_BODY()

public:
    UFUNCTION()
    void AnimNotify_AttackHit() {
        // Called when notify is reached
        DealDamage();
    }
};
```

---

## Blend Space

### 1D Blend Space (속도 블렌딩)

```cpp
// Create: Content Browser > Animation > Blend Space 1D
// Horizontal Axis: Speed (0 = Idle, 1 = Walk, 2 = Run)
// Add animations at key points

// Use in Anim Blueprint:
// - Get speed from character
// - Feed into Blend Space
```

### 2D Blend Space (방향성 이동)

```cpp
// Create: Content Browser > Animation > Blend Space
// Horizontal Axis: Direction X (-1 to 1)
// Vertical Axis: Direction Y (-1 to 1)
// Place animations (Fwd, Back, Left, Right, diagonal)
```

---

## Control Rig (프로시저럴 애니메이션)

### Control Rig 생성

1. Content Browser > Animation > Control Rig
2. 스켈레톤 선택
3. 리그 계층 구성(본, 컨트롤, IK)

### Animation Blueprint에서 Control Rig 사용

```cpp
// Add "Control Rig" node to Anim Blueprint
// Assign Control Rig asset
// Procedurally modify bones at runtime
```

### C++에서 Control Rig 사용

```cpp
// Get control rig component
UControlRig* ControlRig = /* Get from animation instance */;

// Set control value
ControlRig->SetControlValue<FVector>(TEXT("IK_Hand_R"), TargetLocation);
```

---

## IK Rig & 리타겟팅 (UE5)

### IK Rig 생성

1. Content Browser > Animation > IK Rig
2. 스켈레톤 선택
3. IK 골(손, 발) 추가
4. 솔버 체인 설정

### 애니메이션 리타겟팅

1. 소스 스켈레톤용 IK Rig 생성
2. 타겟 스켈레톤용 IK Rig 생성
3. IK Retargeter 에셋 생성
4. 소스 및 타겟 IK Rig 할당
5. 애니메이션 일괄 리타겟

### C++에서의 리타겟팅

```cpp
// Retargeting is primarily editor-based
// Animations are retargeted once, then used normally
```

---

## Animation Notify State

### 커스텀 Notify State (지속 시간 기반 이벤트)

```cpp
UCLASS()
class UAnimNotifyState_Invulnerable : public UAnimNotifyState {
    GENERATED_BODY()

public:
    virtual void NotifyBegin(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, float TotalDuration, const FAnimNotifyEventReference& EventReference) override {
        // Start invulnerability
        AMyCharacter* Character = Cast<AMyCharacter>(MeshComp->GetOwner());
        Character->bIsInvulnerable = true;
    }

    virtual void NotifyEnd(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, const FAnimNotifyEventReference& EventReference) override {
        // End invulnerability
        AMyCharacter* Character = Cast<AMyCharacter>(MeshComp->GetOwner());
        Character->bIsInvulnerable = false;
    }
};
```

---

## Skeletal Mesh & Socket

### 소켓에 오브젝트 부착

```cpp
// Create socket in Skeletal Mesh Editor (Skeleton Tree > Add Socket)

// Attach component to socket
UStaticMeshComponent* Weapon = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Weapon"));
Weapon->SetupAttachment(GetMesh(), TEXT("hand_r_socket"));
```

---

## Animation Curve

### Animation Curve 사용

```cpp
// Add curve to animation:
// Animation Editor > Curves > Add Curve

// Read curve value in Anim Blueprint or C++:
UAnimInstance* AnimInstance = GetMesh()->GetAnimInstance();
float CurveValue = AnimInstance->GetCurveValue(TEXT("MyCurve"));
```

---

## Root Motion

### Root Motion 활성화

```cpp
// In Animation Sequence: Asset Details > Root Motion > Enable Root Motion

// In Character class:
GetCharacterMovement()->bAllowPhysicsRotationDuringAnimRootMotion = true;
```

---

## Animation Layer (Linked Anim Graph)

### Linked Anim Layer 사용

```cpp
// Create separate Anim Blueprints for layers (e.g., upper body, lower body)
// Link in main Anim Blueprint: Add "Linked Anim Graph" node

// Dynamically switch layers:
UAnimInstance* AnimInstance = GetMesh()->GetAnimInstance();
AnimInstance->LinkAnimClassLayers(NewLayerClass);
```

---

## Sequencer (시네마틱 애니메이션)

### Sequence 생성

1. Content Browser > Cinematics > Level Sequence
2. 트랙 추가: Camera, Character, Animation 등

### C++에서 Sequence 재생

```cpp
#include "LevelSequenceActor.h"
#include "LevelSequencePlayer.h"

ALevelSequenceActor* SequenceActor = /* Spawn or find in level */;
SequenceActor->GetSequencePlayer()->Play();
```

---

## 성능 팁

### 애니메이션 최적화

```cpp
// LOD (Level of Detail) for skeletal meshes
// Reduce bone count for distant characters

// Anim Blueprint optimization:
// - Use "Anim Node Relevancy" (skip updates when not visible)
// - Disable updates when off-screen:
GetMesh()->VisibilityBasedAnimTickOption = EVisibilityBasedAnimTickOption::OnlyTickPoseWhenRendered;
```

---

## 디버깅

### 애니메이션 디버그 시각화

```cpp
// Console commands:
// showdebug animation - Show animation state info
// a.VisualizeSkeletalMeshBones 1 - Show skeleton bones

// Draw debug bones:
DrawDebugCoordinateSystem(GetWorld(), BoneLocation, BoneRotation, 50.0f, false, -1.0f, 0, 2.0f);
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/animation-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/control-rig-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/ik-rig-in-unreal-engine/
