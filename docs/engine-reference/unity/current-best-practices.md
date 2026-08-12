# Unity 6.3 LTS — 현재의 모범 사례

**최종 확인일:** 2026-02-13

LLM의 학습 데이터에 없을 수 있는 현대적인 Unity 6 패턴들이다.
Unity 6.3 LTS 기준으로 프로덕션에 적합한 권장 사항들이다.

---

## 프로젝트 설정

### 프로덕션에는 Unity 6.3 LTS를 사용할 것
- **테크 스트림**(6.4+): 최신 기능, 안정성은 낮음
- **LTS**(6.3): 프로덕션에 적합, 2년 지원(2027년 12월까지)

### 적절한 렌더 파이프라인을 선택할 것
- **URP(Universal)**: 모바일, 크로스플랫폼, 좋은 성능 ✅ 대부분의 게임에 권장
- **HDRP(High Definition)**: 하이엔드 PC/콘솔, 포토리얼리스틱
- **Built-in**: 폐기 예정, 신규 프로젝트에는 피할 것

---

## 스크립팅

### C# 9+ 기능을 사용할 것(Unity 6은 C# 9를 지원)

```csharp
// ✅ Record types for data
public record PlayerData(string Name, int Level, float Health);

// ✅ Init-only properties
public class Config {
    public string GameMode { get; init; }
}

// ✅ Pattern matching
var result = enemy switch {
    Boss boss => boss.Enrage(),
    Minion minion => minion.Flee(),
    _ => null
};
```

### 에셋 로딩에는 Async/Await를 사용할 것

```csharp
// ✅ Modern async pattern
public async Task<GameObject> LoadEnemyAsync(string key) {
    var handle = Addressables.LoadAssetAsync<GameObject>(key);
    return await handle.Task;
}
```

### 직렬화에는 소스 생성기를 사용할 것(Unity 6+)

```csharp
// ✅ Source-generated serialization (faster, less reflection)
[GenerateSerializer]
public partial struct PlayerStats : IComponentData {
    public int Health;
    public int Mana;
}
```

---

## DOTS/ECS(Unity 6.3 LTS에서 프로덕션 준비 완료)

### ComponentSystem이 아닌 ISystem을 사용할 것

```csharp
// ✅ Modern unmanaged ISystem (Burst-compatible)
public partial struct MovementSystem : ISystem {
    public void OnCreate(ref SystemState state) { }

    public void OnUpdate(ref SystemState state) {
        foreach (var (transform, speed) in
            SystemAPI.Query<RefRW<LocalTransform>, RefRO<MoveSpeed>>()) {
            transform.ValueRW.Position += speed.ValueRO.Value * SystemAPI.Time.DeltaTime;
        }
    }
}
```

### 병렬 잡에는 IJobEntity를 사용할 것

```csharp
// ✅ IJobEntity (replaces IJobForEach)
[BurstCompile]
public partial struct DamageJob : IJobEntity {
    public float DeltaTime;

    void Execute(ref Health health, in DamageOverTime dot) {
        health.Value -= dot.DamagePerSecond * DeltaTime;
    }
}

// Schedule it
var job = new DamageJob { DeltaTime = SystemAPI.Time.DeltaTime };
job.ScheduleParallel();
```

---

## 입력

### (레거시 Input이 아닌) Input System 패키지를 사용할 것

```csharp
// ✅ Input Actions (rebindable, cross-platform)
using UnityEngine.InputSystem;

public class PlayerInput : MonoBehaviour {
    private PlayerControls controls;

    void Awake() {
        controls = new PlayerControls();
        controls.Gameplay.Jump.performed += ctx => Jump();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();
}
```

에디터에서 Input Actions 에셋을 생성하고, 인스펙터를 통해 C# 클래스를 생성한다.

---

## UI

### 런타임 UI에는 UI Toolkit을 사용할 것(Unity 6에서 프로덕션 준비 완료)

```csharp
// ✅ UI Toolkit (replaces UGUI for new projects)
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour {
    void OnEnable() {
        var root = GetComponent<UIDocument>().rootVisualElement;

        var playButton = root.Q<Button>("play-button");
        playButton.clicked += StartGame;

        var scoreLabel = root.Q<Label>("score");
        scoreLabel.text = $"High Score: {PlayerPrefs.GetInt("HighScore")}";
    }
}
```

**UXML**(UI 구조) + **USS**(스타일링) = HTML/CSS와 유사한 워크플로.

---

## 에셋 관리

### (Resources가 아닌) Addressables를 사용할 것

```csharp
// ✅ Addressables (async, memory-efficient)
using UnityEngine.AddressableAssets;

public async Task SpawnEnemyAsync(string enemyKey) {
    var handle = Addressables.InstantiateAsync(enemyKey);
    var enemy = await handle.Task;

    // Cleanup: release when destroyed
    Addressables.ReleaseInstance(enemy);
}
```

**이점:** 비동기 로딩, 원격 콘텐츠 전달, 더 나은 메모리 제어.

---

## 렌더링

### 커스텀 패스에는 RenderGraph API를 사용할 것(URP/HDRP)

```csharp
// ✅ RenderGraph API (Unity 6+)
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData) {
    using (var builder = renderGraph.AddRasterRenderPass<PassData>("My Pass", out var passData)) {
        // Setup pass
        builder.SetRenderFunc((PassData data, RasterGraphContext context) => {
            // Execute commands
        });
    }
}
```

**대체 대상:** 기존의 `CommandBuffer.Execute()` 패턴.

---

## 성능

### Burst 컴파일러 + Jobs 시스템을 사용할 것

```csharp
// ✅ Burst-compiled job (massive performance gain)
[BurstCompile]
struct ParticleUpdateJob : IJobParallelFor {
    public NativeArray<float3> Positions;
    public NativeArray<float3> Velocities;
    public float DeltaTime;

    public void Execute(int index) {
        Positions[index] += Velocities[index] * DeltaTime;
    }
}

// Schedule
var job = new ParticleUpdateJob {
    Positions = positions,
    Velocities = velocities,
    DeltaTime = Time.deltaTime
};
job.Schedule(positions.Length, 64).Complete();
```

동등한 C# 코드보다 **20~100배 더 빠르다.**

---

### 반복되는 오브젝트에는 GPU 인스턴싱을 사용할 것

```csharp
// ✅ GPU Instancing (thousands of objects, minimal draw calls)
Graphics.RenderMeshInstanced(
    new RenderParams(material),
    mesh,
    0,
    matrices // NativeArray<Matrix4x4>
);
```

---

## 메모리 관리

### (잡 안에서 관리형 배열이 아닌) NativeContainer를 사용할 것

```csharp
// ✅ NativeArray (no GC, Burst-compatible)
NativeArray<int> data = new NativeArray<int>(1000, Allocator.TempJob);
// ... use in job
data.Dispose(); // Manual cleanup required

// ✅ Or use using statement
using var data = new NativeArray<int>(1000, Allocator.TempJob);
// Auto-disposed
```

---

## 멀티플레이어

### (공식) Netcode for GameObjects를 사용할 것

```csharp
// ✅ Unity's official netcode
using Unity.Netcode;

public class Player : NetworkBehaviour {
    private NetworkVariable<int> health = new NetworkVariable<int>(100);

    [ServerRpc]
    public void TakeDamageServerRpc(int damage) {
        health.Value -= damage;
    }
}
```

**대체 대상:** UNet(폐기 예정), MLAPI(Netcode for GameObjects로 명칭 변경됨).

---

## 테스트

### Unity Test Framework(NUnit 기반)를 사용할 것

```csharp
// ✅ Play Mode Test
[UnityTest]
public IEnumerator Player_TakesDamage_HealthDecreases() {
    var player = new GameObject().AddComponent<Player>();
    player.Health = 100;

    player.TakeDamage(25);
    yield return null; // Wait one frame

    Assert.AreEqual(75, player.Health);
}
```

---

## 디버깅

### 로깅 모범 사례를 따를 것

```csharp
// ✅ Structured logging (Unity 6+)
using UnityEngine;

Debug.Log($"Player {playerName} scored {score} points");

// ✅ Conditional compilation for debug code
#if UNITY_EDITOR || DEVELOPMENT_BUILD
    Debug.DrawRay(transform.position, direction, Color.red);
#endif
```

---

## 요약: Unity 6 기술 스택

| 기능 | 이것을 사용(2026년 기준) | 이것은 피할 것(레거시) |
|---------|------------------|----------------------|
| **입력** | Input System 패키지 | `Input` 클래스 |
| **UI** | UI Toolkit | UGUI(Canvas) |
| **ECS** | ISystem + IJobEntity | ComponentSystem |
| **렌더링** | URP + RenderGraph | Built-in 파이프라인 |
| **에셋** | Addressables | Resources |
| **잡** | Burst + IJobParallelFor | 무거운 작업에 코루틴 사용 |
| **멀티플레이어** | Netcode for GameObjects | UNet |

---

**출처:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/BestPracticeGuides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html
