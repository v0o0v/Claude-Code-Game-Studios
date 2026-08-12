# Unity 6.3 LTS — 파괴적 변경사항(Breaking Changes)

**최종 확인일:** 2026-02-13

이 문서는 Unity 2022 LTS(모델 학습 데이터에 포함되어 있을 가능성이 높음)와
Unity 6.3 LTS(현재 버전) 사이의 파괴적 API 변경사항 및 동작 차이를 추적한다.
위험도별로 정리되어 있다.

## 높음(HIGH RISK) — 기존 코드가 깨질 수 있음

### Entities/DOTS API 전면 개편
**버전:** Entities 1.0+(Unity 6.0+)

```csharp
// ❌ OLD (pre-Unity 6, GameObjectEntity pattern)
public class HealthComponent : ComponentData {
    public float Value;
}

// ✅ NEW (Unity 6+, IComponentData)
public struct HealthComponent : IComponentData {
    public float Value;
}

// ❌ OLD: ComponentSystem
public class DamageSystem : ComponentSystem { }

// ✅ NEW: ISystem (unmanaged, Burst-compatible)
public partial struct DamageSystem : ISystem {
    public void OnCreate(ref SystemState state) { }
    public void OnUpdate(ref SystemState state) { }
}
```

**마이그레이션:** Unity의 ECS 마이그레이션 가이드를 따를 것. 대규모 아키텍처 변경이 필요하다.

---

### 입력 시스템 — 레거시 Input 폐기 예정
**버전:** Unity 6.0+

```csharp
// ❌ OLD: Input class (deprecated)
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ NEW: Input System package
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**마이그레이션:** Input System 패키지를 설치하고, 모든 `Input.*` 호출을 새 API로 교체할 것.

---

### URP/HDRP 렌더러 피처 API 변경
**버전:** Unity 6.0+

```csharp
// ❌ OLD: ScriptableRenderPass.Execute signature
public override void Execute(ScriptableRenderContext context, ref RenderingData data)

// ✅ NEW: Uses RenderGraph API
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
```

**마이그레이션:** 커스텀 렌더 패스를 RenderGraph API를 사용하도록 업데이트할 것.

---

## 중간(MEDIUM RISK) — 동작 변경

### Addressables — 에셋 로딩 반환값
**버전:** Unity 6.2+

에셋 로딩 실패 시 이제 기본적으로 null을 반환하는 대신 예외를 던진다.
적절한 예외 처리를 추가하거나 `TryLoad` 계열 메서드를 사용할 것.

```csharp
// ❌ OLD: Silent null on failure
var handle = Addressables.LoadAssetAsync<Sprite>("key");
var sprite = handle.Result; // null if failed

// ✅ NEW: Throws on failure, use try/catch or TryLoad
try {
    var handle = Addressables.LoadAssetAsync<Sprite>("key");
    var sprite = await handle.Task;
} catch (Exception e) {
    Debug.LogError($"Failed to load: {e}");
}
```

---

### 물리 — 기본 솔버 반복 횟수 변경
**버전:** Unity 6.0+

안정성 향상을 위해 기본 솔버 반복 횟수가 증가했다.
기존 동작에 의존하고 있다면 `Physics.defaultSolverIterations`를 확인할 것.

---

## 낮음(LOW RISK) — 폐기 예정(아직 동작함)

### UGUI(레거시 UI)
**상태:** 폐기 예정이지만 지원됨
**대체:** UI Toolkit

UGUI는 여전히 동작하지만, 신규 프로젝트에는 UI Toolkit이 권장된다.

---

### 레거시 파티클 시스템
**상태:** 폐기 예정
**대체:** Visual Effect Graph(VFX Graph)

---

### 구 애니메이션 시스템
**상태:** 폐기 예정
**대체:** Animator Controller(Mecanim)

---

## 플랫폼별 파괴적 변경사항

### WebGL
- **Unity 6.0+**: WebGPU가 이제 기본값(WebGL 2.0 폴백 가능)
- WebGPU 호환을 위해 셰이더 업데이트 필요

### Android
- **Unity 6.0+**: 최소 API 레벨이 24(Android 7.0)로 상향됨

### iOS
- **Unity 6.0+**: 최소 배포 대상이 iOS 13으로 상향됨

---

## 마이그레이션 체크리스트

2022 LTS에서 Unity 6.3 LTS로 업그레이드할 때:

- [ ] 모든 DOTS/ECS 코드를 감사할 것(전면 재작성이 필요할 가능성 높음)
- [ ] `Input` 클래스를 Input System 패키지로 교체할 것
- [ ] 커스텀 렌더 패스를 RenderGraph API로 업데이트할 것
- [ ] Addressables 호출에 예외 처리를 추가할 것
- [ ] 물리 동작을 테스트할 것(솔버 반복 횟수 변경됨)
- [ ] 신규 UI에 대해 UGUI를 UI Toolkit으로 마이그레이션하는 것을 고려할 것
- [ ] WebGPU를 위해 WebGL 셰이더를 업데이트할 것
- [ ] 최소 플랫폼 버전(Android/iOS)을 확인할 것

---

**출처:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/upgrade-guide.html
