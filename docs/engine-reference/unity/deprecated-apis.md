# Unity 6.3 LTS — 폐기 예정 API

**최종 확인일:** 2026-02-13

폐기 예정 API와 그 대체재를 위한 빠른 조회 표.
형식: **X를 쓰지 말 것** → **대신 Y를 쓸 것**

---

## 입력

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `Input.GetKey()` | `Keyboard.current[Key.X].isPressed` | 새 입력 시스템 |
| `Input.GetKeyDown()` | `Keyboard.current[Key.X].wasPressedThisFrame` | 새 입력 시스템 |
| `Input.GetMouseButton()` | `Mouse.current.leftButton.isPressed` | 새 입력 시스템 |
| `Input.GetAxis()` | `InputAction` 콜백 | 새 입력 시스템 |
| `Input.mousePosition` | `Mouse.current.position.ReadValue()` | 새 입력 시스템 |

**마이그레이션:** `com.unity.inputsystem` 패키지를 설치할 것.

---

## UI

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `Canvas`(UGUI) | `UIDocument`(UI Toolkit) | UI Toolkit이 이제 프로덕션 준비 완료 |
| `Text` 컴포넌트 | `TextMeshPro` 또는 UI Toolkit `Label` | 더 나은 렌더링, 더 적은 드로우 콜 |
| `Image` 컴포넌트 | 배경을 가진 UI Toolkit `VisualElement` | 더 유연한 스타일링 |

**마이그레이션:** UGUI는 여전히 동작하지만, 신규 프로젝트에는 UI Toolkit이 권장된다.

---

## DOTS/Entities

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `ComponentSystem` | `ISystem`(unmanaged) | Entities 1.0+ 전면 재작성 |
| `JobComponentSystem` | `IJobEntity`를 사용하는 `ISystem` | Burst 호환 |
| `GameObjectEntity` | 순수 ECS 워크플로 | GameObject 변환 없음 |
| `EntityManager.CreateEntity()`(구 시그니처) | `EntityManager.CreateEntity(EntityArchetype)` | 명시적 아키타입 |
| `ComponentDataFromEntity<T>` | `ComponentLookup<T>` | Entities 1.0+ 명칭 변경 |

**마이그레이션:** Entities 패키지 마이그레이션 가이드를 참고할 것. 대규모 리팩터링이 필요하다.

---

## 렌더링

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `CommandBuffer.DrawMesh()` | RenderGraph API | URP/HDRP 렌더 패스 |
| `OnPreRender()` / `OnPostRender()` | `RenderPipelineManager` 콜백 | SRP 호환성 |
| `Camera.SetReplacementShader()` | 커스텀 렌더 패스 | SRP에서 미지원 |

---

## 물리

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `Physics.RaycastAll()` | `Physics.RaycastNonAlloc()` | GC 할당 회피 |
| `Rigidbody.velocity`(직접 대입) | `Rigidbody.AddForce()` | 더 나은 물리 안정성 |

---

## 에셋 로딩

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `Resources.Load()` | Addressables | 더 나은 메모리 제어, 비동기 로딩 |
| 동기식 에셋 로딩 | `Addressables.LoadAssetAsync()` | 논블로킹 |

---

## 애니메이션

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| 레거시 Animation 컴포넌트 | Animator Controller | Mecanim 시스템 |
| `Animation.Play()` | `Animator.Play()` | 상태 머신 제어 |

---

## 파티클

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| 레거시 파티클 시스템 | Visual Effect Graph | GPU 가속, 더 높은 성능 |

---

## 스크립팅

| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| `WWW` 클래스 | `UnityWebRequest` | 현대적인 비동기 네트워킹 |
| `Application.LoadLevel()` | `SceneManager.LoadScene()` | 씬 관리 |

---

## 플랫폼별

### WebGL
| 폐기 예정 | 대체재 | 비고 |
|------------|-------------|-------|
| WebGL 1.0 | WebGL 2.0 또는 WebGPU | Unity 6+는 WebGPU를 기본값으로 사용 |

---

## 빠른 마이그레이션 패턴

### 입력 예시
```csharp
// ❌ Deprecated
if (Input.GetKeyDown(KeyCode.Space)) {
    Jump();
}

// ✅ New Input System
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) {
    Jump();
}
```

### 에셋 로딩 예시
```csharp
// ❌ Deprecated
var prefab = Resources.Load<GameObject>("Enemies/Goblin");

// ✅ Addressables
var handle = Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin");
await handle.Task;
var prefab = handle.Result;
```

### UI 예시
```csharp
// ❌ Deprecated (UGUI)
GetComponent<Text>().text = "Score: 100";

// ✅ TextMeshPro
GetComponent<TextMeshProUGUI>().text = "Score: 100";

// ✅ UI Toolkit
rootVisualElement.Q<Label>("score-label").text = "Score: 100";
```

---

**출처:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/deprecated-features.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/Migration.html
