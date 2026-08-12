# Unity 6.3 — 입력 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** Unity 6은 새로운 Input System을 사용함(레거시 Input은 지원 중단)

---

## 개요

Unity 6 입력 시스템:
- **Input System Package** (권장): 크로스 플랫폼, 리바인딩 가능, 최신 방식
- **Legacy Input Manager**: 지원 중단, 신규 프로젝트에는 사용 지양

---

## 2022 LTS 대비 주요 변경 사항

### Unity 6에서 Legacy Input 지원 중단

```csharp
// ❌ 지원 중단(DEPRECATED): Input 클래스
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ 신규: Input System 패키지
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**마이그레이션 필요:** `com.unity.inputsystem` 패키지를 설치해야 함.

---

## Input System 패키지 설정

### 설치

1. `Window > Package Manager`
2. "Input System" 검색
3. 패키지 설치
4. 안내 시 Unity 재시작

### 새 Input System 활성화

`Edit > Project Settings > Player > Active Input Handling`:
- **Input System Package (New)** ✅ 권장
- **Both** (마이그레이션 기간에 사용)

---

## Input Actions (권장 패턴)

### Input Actions 에셋 생성

1. `Assets > Create > Input Actions`
2. 이름 지정(예: "PlayerControls")
3. 에셋을 열고 액션 정의:

```
Action Maps:
  Gameplay
    Actions:
      - Move (Value, Vector2)
      - Jump (Button)
      - Fire (Button)
      - Look (Value, Vector2)
```

4. **C# 클래스 생성**: Inspector에서 "Generate C# Class" 체크
5. "Apply" 클릭

### 생성된 Input 클래스 사용

```csharp
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour {
    private PlayerControls controls;

    void Awake() {
        controls = new PlayerControls();

        // 액션 구독
        controls.Gameplay.Jump.performed += ctx => Jump();
        controls.Gameplay.Fire.performed += ctx => Fire();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();

    void Update() {
        // 연속 입력 읽기
        Vector2 move = controls.Gameplay.Move.ReadValue<Vector2>();
        transform.Translate(new Vector3(move.x, 0, move.y) * Time.deltaTime);

        Vector2 look = controls.Gameplay.Look.ReadValue<Vector2>();
        // 카메라 회전 적용
    }

    void Jump() {
        Debug.Log("Jump!");
    }

    void Fire() {
        Debug.Log("Fire!");
    }
}
```

---

## 디바이스 직접 접근 (빠르고 간단한 방식)

### 키보드

```csharp
using UnityEngine.InputSystem;

void Update() {
    // 현재 상태
    if (Keyboard.current.spaceKey.isPressed) { }

    // 이번 프레임에 방금 눌림
    if (Keyboard.current.spaceKey.wasPressedThisFrame) { }

    // 이번 프레임에 방금 떼어짐
    if (Keyboard.current.spaceKey.wasReleasedThisFrame) { }
}
```

### 마우스

```csharp
using UnityEngine.InputSystem;

void Update() {
    // 마우스 위치
    Vector2 mousePos = Mouse.current.position.ReadValue();

    // 마우스 델타(이동량)
    Vector2 mouseDelta = Mouse.current.delta.ReadValue();

    // 마우스 버튼
    if (Mouse.current.leftButton.wasPressedThisFrame) { }
    if (Mouse.current.rightButton.isPressed) { }

    // 스크롤 휠
    Vector2 scroll = Mouse.current.scroll.ReadValue();
}
```

### 게임패드

```csharp
using UnityEngine.InputSystem;

void Update() {
    Gamepad gamepad = Gamepad.current;
    if (gamepad == null) return; // 연결된 게임패드 없음

    // 버튼
    if (gamepad.buttonSouth.wasPressedThisFrame) { } // A/Cross
    if (gamepad.buttonWest.wasPressedThisFrame) { }  // X/Square

    // 스틱
    Vector2 leftStick = gamepad.leftStick.ReadValue();
    Vector2 rightStick = gamepad.rightStick.ReadValue();

    // 트리거
    float leftTrigger = gamepad.leftTrigger.ReadValue();
    float rightTrigger = gamepad.rightTrigger.ReadValue();

    // D-Pad
    Vector2 dpad = gamepad.dpad.ReadValue();
}
```

### 터치 (모바일)

```csharp
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.EnhancedTouch;

void OnEnable() {
    EnhancedTouchSupport.Enable();
}

void Update() {
    foreach (var touch in UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches) {
        Debug.Log($"Touch at {touch.screenPosition}");
    }
}
```

---

## Input Action 콜백

### 액션 콜백 (이벤트 기반)

```csharp
// started: 입력이 시작됨(예: 트리거가 살짝 눌림)
controls.Gameplay.Fire.started += ctx => Debug.Log("Fire started");

// performed: 입력 액션이 트리거됨(예: 버튼이 완전히 눌림)
controls.Gameplay.Fire.performed += ctx => Debug.Log("Fire performed");

// canceled: 입력이 해제되거나 중단됨
controls.Gameplay.Fire.canceled += ctx => Debug.Log("Fire canceled");
```

### 컨텍스트 데이터

```csharp
controls.Gameplay.Move.performed += ctx => {
    Vector2 value = ctx.ReadValue<Vector2>();
    float duration = ctx.duration; // 입력이 유지된 시간
    InputControl control = ctx.control; // 트리거한 디바이스/컨트롤
};
```

---

## 컨트롤 스킴 & 디바이스 전환

### Input Actions 에셋에서 컨트롤 스킴 정의

```
Control Schemes:
  - Keyboard&Mouse (Keyboard, Mouse)
  - Gamepad (Gamepad)
  - Touch (Touchscreen)
```

### 디바이스 변경 시 자동 전환

```csharp
controls.Gameplay.Move.performed += ctx => {
    if (ctx.control.device is Keyboard) {
        Debug.Log("Using keyboard");
    } else if (ctx.control.device is Gamepad) {
        Debug.Log("Using gamepad");
    }
};
```

---

## 리바인딩 (런타임 키 매핑)

### 인터랙티브 리바인딩

```csharp
using UnityEngine.InputSystem;

public void RebindJumpKey() {
    var rebindOperation = controls.Gameplay.Jump.PerformInteractiveRebinding()
        .WithControlsExcluding("Mouse") // 마우스 바인딩 제외
        .OnComplete(operation => {
            Debug.Log("Rebind complete");
            operation.Dispose();
        })
        .Start();
}
```

### 바인딩 저장/불러오기

```csharp
// 저장
string rebinds = controls.SaveBindingOverridesAsJson();
PlayerPrefs.SetString("InputBindings", rebinds);

// 불러오기
string rebinds = PlayerPrefs.GetString("InputBindings");
controls.LoadBindingOverridesFromJson(rebinds);
```

---

## 액션 타입

### Button (누름/뗌)
- 단일 누름/뗌
- 예: Jump, Fire

### Value (연속값)
- 연속적인 값(float, Vector2)
- 예: Move, Look, Aim

### Pass-Through (즉시 전달)
- 별도 처리 없이 즉시 값 전달
- 예: 마우스 위치

---

## Processors (입력 보정기)

### Scale

```csharp
// In Input Actions asset: Action > Properties > Processors > Add > Scale
// 입력값에 특정 값을 곱함(예: Y축 반전)
```

### Invert

```csharp
// In Input Actions asset: Action > Properties > Processors > Add > Invert
// 입력 부호 반전
```

### Dead Zone

```csharp
// In Input Actions asset: Action > Properties > Processors > Add > Stick Deadzone
// 작은 스틱 움직임 무시
```

---

## PlayerInput 컴포넌트 (간소화된 설정)

### 자동 입력 설정

```csharp
// Add Component: Player Input
// Assign Input Actions asset
// Behavior: Send Messages / Invoke Unity Events / Invoke C# Events

// Send Messages 예시:
public class Player : MonoBehaviour {
    public void OnMove(InputValue value) {
        Vector2 move = value.Get<Vector2>();
        // 이동 처리
    }

    public void OnJump(InputValue value) {
        if (value.isPressed) {
            Jump();
        }
    }
}
```

---

## 디버깅

### Input Debugger
- `Window > Analysis > Input Debugger`
- 활성 디바이스, 입력값, 액션 상태 확인

---

## 출처
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/QuickStartGuide.html
