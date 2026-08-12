# Unity 6.3 — DOTS / Entities (ECS)

**최종 확인일:** 2026-02-13
**상태:** 프로덕션 준비 완료 (Entities 1.3+, Unity 6.3 LTS)
**패키지:** `com.unity.entities` (Package Manager)

---

## 개요

**DOTS (Data-Oriented Technology Stack)**는 Unity의 고성능 ECS(Entity Component System)
프레임워크다. 대규모 게임(수천~수만 개의 엔티티)을 위해 설계되었다.

**DOTS를 사용해야 하는 경우:**
- RTS 게임 (수천 개의 유닛)
- 시뮬레이션 (군중, 교통, 물리)
- 절차적 콘텐츠 생성
- 성능이 중요한 시스템

**DOTS를 사용하지 말아야 하는 경우:**
- 소규모 게임 (오버헤드가 그만한 가치가 없음)
- 구조적 변경이 잦은 게임플레이
- UnityEngine API를 많이 사용하는 경우 (MonoBehaviour가 더 쉬움)

**⚠️ 지식 공백:** Entities 1.0+ (Unity 6)은 0.x 버전을 완전히 재작성한 것이다.
Entities 0.x용 튜토리얼 다수는 현재 시대에 뒤떨어져 있다.

---

## 설치

### Package Manager를 통한 설치

1. `Window > Package Manager`
2. Unity Registry > "Entities" 검색
3. 설치할 항목:
   - `Entities` (ECS 코어)
   - `Burst` (LLVM 컴파일러)
   - `Jobs` (자동 설치됨)
   - `Mathematics` (SIMD 수학 연산)

---

## 핵심 개념

### 1. **엔티티 (Entity)**
- 가벼운 ID (int)
- 동작을 가지지 않으며, 단지 식별자일 뿐

### 2. **컴포넌트 (Component)**
- 데이터만 존재 (메서드 없음)
- `IComponentData`를 구현하는 struct

### 3. **시스템 (System)**
- 컴포넌트를 처리하는 로직
- `ISystem`을 구현하는 struct

### 4. **아키타입 (Archetype)**
- 컴포넌트 타입들의 고유한 조합
- 같은 컴포넌트를 가진 엔티티들은 같은 아키타입을 공유함

---

## 기본 ECS 패턴

### 컴포넌트 정의

```csharp
using Unity.Entities;
using Unity.Mathematics;

// ✅ 컴포넌트: 데이터만 존재, 메서드 없음
public struct Position : IComponentData {
    public float3 Value;
}

public struct Velocity : IComponentData {
    public float3 Value;
}
```

---

### 시스템 정의

```csharp
using Unity.Entities;
using Unity.Burst;

// ✅ 시스템: 엔티티를 처리하는 로직
[BurstCompile]
public partial struct MovementSystem : ISystem {
    [BurstCompile]
    public void OnUpdate(ref SystemState state) {
        float deltaTime = SystemAPI.Time.DeltaTime;

        // Position + Velocity를 가진 모든 엔티티를 쿼리
        foreach (var (transform, velocity) in
            SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()) {

            transform.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
        }
    }
}
```

---

### 엔티티 생성

```csharp
using Unity.Entities;
using Unity.Mathematics;

public partial class EntitySpawner : SystemBase {
    protected override void OnUpdate() {
        var em = EntityManager;

        // 엔티티 생성
        Entity entity = em.CreateEntity();

        // 컴포넌트 추가
        em.AddComponentData(entity, new Position { Value = float3.zero });
        em.AddComponentData(entity, new Velocity { Value = new float3(1, 0, 0) });
    }
}
```

---

## 하이브리드 ECS (MonoBehaviour + ECS)

### 베이커 (GameObject를 Entity로 변환)

```csharp
using Unity.Entities;
using UnityEngine;

public class PlayerAuthoring : MonoBehaviour {
    public float speed;
}

public class PlayerBaker : Baker<PlayerAuthoring> {
    public override void Bake(PlayerAuthoring authoring) {
        var entity = GetEntity(TransformUsageFlags.Dynamic);

        AddComponent(entity, new Position { Value = authoring.transform.position });
        AddComponent(entity, new Velocity { Value = new float3(authoring.speed, 0, 0) });
    }
}
```

**동작 방식:**
1. 에디터에서 GameObject에 `PlayerAuthoring`을 추가
2. Baker가 런타임에 자동으로 Entity로 변환함
3. Entity는 Position + Velocity 컴포넌트를 가지게 됨

---

## 쿼리 (Queries)

### 컴포넌트를 가진 모든 엔티티 쿼리

```csharp
foreach (var (position, velocity) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()) {

    position.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
}
```

---

### 엔티티를 포함한 쿼리

```csharp
foreach (var (position, velocity, entity) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>().WithEntityAccess()) {

    // 엔티티 ID에 접근
    Debug.Log($"Entity: {entity}");
}
```

---

### 필터를 사용한 쿼리

```csharp
// "Enemy" 태그를 가진 엔티티만
foreach (var position in
    SystemAPI.Query<RefRW<Position>>().WithAll<EnemyTag>()) {
    // 적(enemy)만 처리
}
```

---

## Jobs (병렬 실행)

### IJobEntity (병렬 Foreach)

```csharp
using Unity.Entities;
using Unity.Burst;

[BurstCompile]
public partial struct MovementJob : IJobEntity {
    public float DeltaTime;

    // Execute는 각 엔티티에 대해 병렬로 실행됨
    void Execute(ref Position position, in Velocity velocity) {
        position.Value += velocity.Value * DeltaTime;
    }
}

[BurstCompile]
public partial struct MovementSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        var job = new MovementJob {
            DeltaTime = SystemAPI.Time.DeltaTime
        };
        job.ScheduleParallel(); // 병렬 실행
    }
}
```

---

## Burst 컴파일러 (성능)

### Burst 활성화

```csharp
using Unity.Burst;

[BurstCompile] // 일반 C#보다 10~100배 빠름
public partial struct MySystem : ISystem {
    [BurstCompile]
    public void OnUpdate(ref SystemState state) {
        // Burst로 컴파일된 코드
    }
}
```

**Burst 제약 사항:**
- 매니지드 참조 불가 (클래스, 문자열 등)
- blittable 타입만 가능 (struct, 기본형, Unity.Mathematics 타입)
- 예외(exception) 사용 불가

---

## Entity Command Buffer (구조적 변경)

### 지연된 구조적 변경

```csharp
using Unity.Entities;

public partial struct SpawnSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        var ecb = new EntityCommandBuffer(Allocator.Temp);

        // 엔티티 생성을 지연시킴 (순회 도중에는 수정하지 않음)
        foreach (var spawner in SystemAPI.Query<Spawner>()) {
            Entity newEntity = ecb.CreateEntity();
            ecb.AddComponent(newEntity, new Position { Value = spawner.SpawnPos });
        }

        ecb.Playback(state.EntityManager); // 변경 사항 적용
        ecb.Dispose();
    }
}
```

---

## 동적 버퍼 (배열 형태의 컴포넌트)

### 동적 버퍼 정의

```csharp
public struct PathWaypoint : IBufferElementData {
    public float3 Position;
}
```

### 동적 버퍼 사용

```csharp
// 엔티티에 버퍼 추가
var buffer = EntityManager.AddBuffer<PathWaypoint>(entity);
buffer.Add(new PathWaypoint { Position = new float3(0, 0, 0) });
buffer.Add(new PathWaypoint { Position = new float3(10, 0, 0) });

// 버퍼 쿼리
foreach (var buffer in SystemAPI.Query<DynamicBuffer<PathWaypoint>>()) {
    foreach (var waypoint in buffer) {
        Debug.Log(waypoint.Position);
    }
}
```

---

## 태그 (크기가 없는 컴포넌트)

### 태그 정의

```csharp
public struct EnemyTag : IComponentData { } // 빈 컴포넌트 = 태그
```

### 필터링용 태그 사용

```csharp
// EnemyTag를 가진 엔티티만 처리
foreach (var position in
    SystemAPI.Query<RefRW<Position>>().WithAll<EnemyTag>()) {
    // 적 전용 로직
}
```

---

## 시스템 순서

### 명시적 순서 지정

```csharp
[UpdateBefore(typeof(PhysicsSystem))]
public partial struct InputSystem : ISystem { }

[UpdateAfter(typeof(PhysicsSystem))]
public partial struct RenderSystem : ISystem { }
```

---

## 성능 패턴

### 청크 순회 (최대 성능)

```csharp
public void OnUpdate(ref SystemState state) {
    var query = SystemAPI.QueryBuilder().WithAll<Position, Velocity>().Build();

    var chunks = query.ToArchetypeChunkArray(Allocator.Temp);
    var positionType = state.GetComponentTypeHandle<Position>();
    var velocityType = state.GetComponentTypeHandle<Velocity>(true); // 읽기 전용

    foreach (var chunk in chunks) {
        var positions = chunk.GetNativeArray(ref positionType);
        var velocities = chunk.GetNativeArray(ref velocityType);

        for (int i = 0; i < chunk.Count; i++) {
            positions[i] = new Position {
                Value = positions[i].Value + velocities[i].Value * deltaTime
            };
        }
    }

    chunks.Dispose();
}
```

---

## MonoBehaviour로부터의 마이그레이션

```csharp
// ❌ 이전 방식: MonoBehaviour (OOP)
public class Enemy : MonoBehaviour {
    public float speed;
    void Update() {
        transform.position += Vector3.forward * speed * Time.deltaTime;
    }
}

// ✅ 새로운 방식: DOTS (ECS)
public struct EnemyData : IComponentData {
    public float Speed;
}

[BurstCompile]
public partial struct EnemyMovementSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        float dt = SystemAPI.Time.DeltaTime;
        foreach (var (transform, enemy) in
            SystemAPI.Query<RefRW<LocalTransform>, RefRO<EnemyData>>()) {
            transform.ValueRW.Position += new float3(0, 0, enemy.ValueRO.Speed * dt);
        }
    }
}
```

---

## 디버깅

### Entities Hierarchy 창

`Window > Entities > Hierarchy`

- 모든 엔티티와 그 컴포넌트를 표시
- 아키타입, 컴포넌트 타입별로 필터링 가능

### Entities Profiler

`Window > Analysis > Profiler > Entities`

- 시스템 실행 시간
- 아키타입별 메모리 사용량

---

## 출처
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.burst@1.8/manual/index.html
- https://learn.unity.com/tutorial/entity-component-system
