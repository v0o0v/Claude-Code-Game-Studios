# Unreal Engine 5.7 — 입력 모듈 레퍼런스

**최종 검증일:** 2026-02-13
**지식 공백:** UE 5.7은 Enhanced Input을 기본값으로 사용(레거시 입력은 폐기 예정)

---

## 개요

UE 5.7 입력 시스템:
- **Enhanced Input** (권장, UE5 기본값): 모듈형, 리바인딩 가능, 컨텍스트 기반
- **Legacy Input**: 폐기 예정, 신규 프로젝트에서는 사용 지양

---

## Enhanced Input 시스템

### Enhanced Input 설정

1. **플러그인 활성화**: `Edit > Plugins > Enhanced Input` (UE5에서 기본 활성화)
2. **프로젝트 설정**: `Engine > Input > Default Classes > Default Player Input Class = EnhancedPlayerInput`

---

### Input Action 생성

1. Content Browser > Input > Input Action
2. 이름 지정(예: `IA_Jump`, `IA_Move`)
3. 구성:
   - **Value Type**: Digital (bool), Axis1D (float), Axis2D (Vector2D), Axis3D (Vector)

Input Action 예시:
- `IA_Jump`: Digital (bool)
- `IA_Move`: Axis2D (Vector2D)
- `IA_Look`: Axis2D (Vector2D)
- `IA_Fire`: Digital (bool)

---

### Input Mapping Context 생성

1. Content Browser > Input > Input Mapping Context
2. 이름 지정(예: `IMC_Default`)
3. 매핑 추가:
   - `IA_Jump` → Space Bar
   - `IA_Move` → W/A/S/D 키(X/Y 결합)
   - `IA_Look` → 마우스 XY
   - `IA_Fire` → 마우스 왼쪽 버튼

---

### C++에서 입력 바인딩

```cpp
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputActionValue.h"

class AMyCharacter : public ACharacter {
public:
    // Input Actions (assign in Blueprint)
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> MoveAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> LookAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputAction> JumpAction;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
    TObjectPtr<UInputMappingContext> DefaultMappingContext;

protected:
    virtual void BeginPlay() override {
        Super::BeginPlay();

        // Add Input Mapping Context
        if (APlayerController* PC = Cast<APlayerController>(Controller)) {
            if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
                ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
                Subsystem->AddMappingContext(DefaultMappingContext, 0);
            }
        }
    }

    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override {
        Super::SetupPlayerInputComponent(PlayerInputComponent);

        UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
        if (EIC) {
            // Bind actions
            EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
            EIC->BindAction(JumpAction, ETriggerEvent::Completed, this, &ACharacter::StopJumping);

            EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
            EIC->BindAction(LookAction, ETriggerEvent::Triggered, this, &AMyCharacter::Look);
        }
    }

    void Move(const FInputActionValue& Value) {
        FVector2D MoveVector = Value.Get<FVector2D>();

        if (Controller) {
            AddMovementInput(GetActorForwardVector(), MoveVector.Y);
            AddMovementInput(GetActorRightVector(), MoveVector.X);
        }
    }

    void Look(const FInputActionValue& Value) {
        FVector2D LookVector = Value.Get<FVector2D>();

        if (Controller) {
            AddControllerYawInput(LookVector.X);
            AddControllerPitchInput(LookVector.Y);
        }
    }
};
```

---

## Input Trigger

### Trigger 유형

Input Action은 언제 발동할지를 제어하는 트리거를 가질 수 있다:
- **Pressed**: 입력이 시작될 때
- **Released**: 입력이 끝날 때
- **Hold**: 일정 시간 동안 유지
- **Tap**: 짧게 누르기
- **Pulse**: 누르고 있는 동안 반복 발동

### 에디터에서 Trigger 추가

1. Input Action 에셋 열기
2. Triggers > Add > 트리거 유형 선택(예: `Hold`)
3. 구성(예: Hold Time = 0.5s)

---

## Input Modifier

### Modifier 유형

Modifier는 입력 값을 변형한다:
- **Negate**: 부호 반전 (-1 ↔ 1)
- **Dead Zone**: 작은 입력 무시
- **Scalar**: 값 배율 적용
- **Smooth**: 시간에 따른 스무딩

### 에디터에서 Modifier 추가

1. Input Action 에셋 열기
2. Modifiers > Add > modifier 선택(예: `Negate`)
3. 구성

---

## Input Mapping Context (컨텍스트 전환)

### 다중 컨텍스트

```cpp
// Define contexts
UPROPERTY(EditAnywhere, Category = "Input")
TObjectPtr<UInputMappingContext> DefaultContext;

UPROPERTY(EditAnywhere, Category = "Input")
TObjectPtr<UInputMappingContext> VehicleContext;

// Switch context
void EnterVehicle() {
    if (APlayerController* PC = Cast<APlayerController>(Controller)) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->RemoveMappingContext(DefaultContext);
            Subsystem->AddMappingContext(VehicleContext, 0);
        }
    }
}
```

---

## Legacy Input (폐기 예정)

### Legacy Input 바인딩

```cpp
// ❌ DEPRECATED: Do not use for new projects

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    // Legacy action binding
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

    // Legacy axis binding
    PlayerInputComponent->BindAxis("MoveForward", this, &AMyCharacter::MoveForward);
}

void MoveForward(float Value) {
    AddMovementInput(GetActorForwardVector(), Value);
}
```

**마이그레이션:** Enhanced Input을 대신 사용할 것.

---

## 게임패드 입력

### Enhanced Input을 사용한 게임패드

```cpp
// Input Mapping Context:
// - IA_Move → Gamepad Left Thumbstick
// - IA_Look → Gamepad Right Thumbstick
// - IA_Jump → Gamepad Face Button Bottom (A/Cross)

// No code changes needed, just add gamepad mappings to Input Mapping Context
```

---

## 터치 입력 (모바일)

### Enhanced Input을 사용한 터치 입력

```cpp
// Input Mapping Context:
// - IA_Move → Touch (virtual thumbstick)
// - IA_Look → Touch (swipe)

// Use Touch Interface asset for virtual controls
```

---

## 런타임 입력 리바인딩

### 키 매핑 변경

```cpp
#include "PlayerMappableInputConfig.h"

// Get subsystem
UEnhancedInputLocalPlayerSubsystem* Subsystem = /* Get subsystem */;

// Get player mappable keys
FPlayerMappableKeySlot KeySlot = FPlayerMappableKeySlot(/*..*/);
FKey NewKey = EKeys::F; // Rebind to F key

// Apply new mapping
Subsystem->AddPlayerMappedKey(/*..*/);
```

---

## 입력 디버깅

### 입력 디버그

```cpp
// Console commands:
// showdebug input - Show input debug info

// Log input values:
UE_LOG(LogTemp, Warning, TEXT("Move Input: %s"), *MoveVector.ToString());
```

---

## 일반적인 패턴

### 키가 눌렸는지 확인 (간단한 방식)

```cpp
// For debugging only (not recommended for gameplay)
if (GetWorld()->GetFirstPlayerController()->IsInputKeyDown(EKeys::SpaceBar)) {
    // Space bar is down
}
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/enhanced-input-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/enhanced-input-action-and-input-mapping-context-in-unreal-engine/
