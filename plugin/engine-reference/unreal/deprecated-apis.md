# Unreal Engine 5.7 — 지원 중단된(Deprecated) API

**최종 확인일:** 2026-02-13

지원 중단된 API와 그 대체 항목을 빠르게 찾아볼 수 있는 표.
형식: **X를 사용하지 말 것** → **대신 Y를 사용할 것**

---

## 입력

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| `InputComponent->BindAction()` | Enhanced Input `BindAction()` | 새로운 입력 시스템 |
| `InputComponent->BindAxis()` | Enhanced Input `BindAxis()` | 새로운 입력 시스템 |
| `PlayerController->GetInputAxisValue()` | Enhanced Input Action Values | 새로운 입력 시스템 |

**마이그레이션:** Enhanced Input 플러그인을 설치하고 Input Actions와 Input Mapping Contexts를 생성한다.

---

## 렌더링

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| Legacy material nodes | Substrate material nodes | Substrate는 5.7에서 프로덕션 준비 완료 |
| Forward shading(기본값) | Deferred + Lumen | Lumen이 UE5의 기본값 |
| Old lighting workflow | Lumen Global Illumination | 실시간 GI |

---

## 월드 빌딩

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| UE4 World Composition | World Partition(UE5) | 대규모 월드 스트리밍 |
| Level Streaming Volumes | World Partition Data Layers | 더 나은 레벨 스트리밍 |

---

## 애니메이션

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| Old animation retargeting | IK Rig + IK Retargeter | UE5 리타게팅 시스템 |
| Legacy control rig | Control Rig 2.0 | 프로덕션 준비가 완료된 리깅 |

---

## 게임플레이

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| `UGameplayStatics::LoadStreamLevel()` | World Partition streaming | Data Layers를 사용할 것 |
| Hardcoded input bindings | Enhanced Input system | 리바인딩 가능한 모듈형 입력 |

---

## Niagara(VFX)

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| Cascade particle system | Niagara | Cascade는 완전히 지원 중단됨 |

---

## 오디오

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| Old audio mixer | MetaSounds | 절차적 오디오 시스템 |
| Sound Cue(복잡한 로직용) | MetaSounds | 더 강력하고 노드 기반 |

---

## 네트워킹

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| `DOREPLIFETIME()`(기본형) | `DOREPLIFETIME_CONDITION()` | 최적화를 위한 조건부 리플리케이션 |

---

## C++ 스크립팅

| 지원 중단 | 대체 | 비고 |
|------------|-------------|-------|
| UObject용 `TSharedPtr<T>` | `TObjectPtr<T>` | UE5 타입 안전 포인터 |
| 수동 RTTI 검사 | `Cast<T>()` / `IsA<T>()` | 타입 안전 캐스팅 |

---

## 빠른 마이그레이션 패턴

### 입력 예시
```cpp
// ❌ Deprecated
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
}

// ✅ Enhanced Input
#include "EnhancedInputComponent.h"

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    if (EIC) {
        EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    }
}
```

### 머티리얼 예시
```cpp
// ❌ Deprecated: Legacy material
// Use standard material graph (still works but not recommended)

// ✅ Substrate Material
// Enable: Project Settings > Engine > Substrate > Enable Substrate
// Use Substrate nodes in material editor
```

### World Partition 예시
```cpp
// ❌ Deprecated: Level streaming volumes
// Load/unload levels manually

// ✅ World Partition
// Enable: World Settings > Enable World Partition
// Use Data Layers for streaming
```

### 파티클 시스템 예시
```cpp
// ❌ Deprecated: Cascade
UParticleSystemComponent* PSC = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("Particles"));

// ✅ Niagara
UNiagaraComponent* NiagaraComp = CreateDefaultSubobject<UNiagaraComponent>(TEXT("Niagara"));
```

### 오디오 예시
```cpp
// ❌ Deprecated: Sound Cue for complex logic
// Use Sound Cue editor nodes

// ✅ MetaSounds
// Create MetaSound Source asset, use node-based audio
```

---

## 요약: UE 5.7 기술 스택

| 기능 | 이것을 사용할 것(2026) | 이것은 피할 것(레거시) |
|---------|------------------|----------------------|
| **입력** | Enhanced Input | Legacy Input Bindings |
| **머티리얼** | Substrate | Legacy Material System |
| **조명** | Lumen + Megalights | Lightmaps + Limited Lights |
| **파티클** | Niagara | Cascade |
| **오디오** | MetaSounds | Sound Cue(로직용) |
| **월드 스트리밍** | World Partition | World Composition |
| **애니메이션 리타게팅** | IK Rig + Retargeter | Old Retargeting |
| **지오메트리** | Nanite(고폴리곤) | Standard Static Mesh LODs |

---

**출처:**
- https://docs.unrealengine.com/5.7/en-US/deprecated-and-removed-features/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
