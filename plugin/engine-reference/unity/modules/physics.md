# Unity 6.3 — 물리 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** Unity 6 물리 개선 사항, 솔버 변경

---

## 개요

Unity 6.3은 **PhysX 5.1**을 사용 (2022 LTS의 PhysX 4.x에서 개선됨):
- 더 나은 솔버 안정성
- 향상된 성능
- 강화된 충돌 감지

---

## 2022 LTS 대비 주요 변경 사항

### 기본 솔버 반복 횟수 증가
Unity 6은 더 나은 안정성을 위해 기본 솔버 반복 횟수를 늘렸습니다:

```csharp
// Default changed from 6 to 8 iterations
Physics.defaultSolverIterations = 8; // Check if relying on old behavior
```

### 강화된 충돌 감지

```csharp
// ✅ Unity 6: Improved Continuous Collision Detection (CCD)
rigidbody.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
// Better handling of fast-moving objects
```

---

## 핵심 물리 컴포넌트

### Rigidbody

```csharp
// ✅ Best practice: Use AddForce, not direct velocity writes
Rigidbody rb = GetComponent<Rigidbody>();
rb.AddForce(Vector3.forward * 10f, ForceMode.Impulse);

// ❌ Avoid: Direct velocity assignment (can cause instability)
rb.velocity = new Vector3(0, 10, 0); // Only use when necessary
```

### Collider

```csharp
// Primitive colliders: Box, Sphere, Capsule (cheapest)
// Mesh colliders: Expensive, use only for static geometry

// ✅ Compound colliders (multiple primitives) > single mesh collider
```

---

## 레이캐스팅

### 효율적인 레이캐스팅 (할당 회피)

```csharp
// ✅ Non-allocating raycast
if (Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance)) {
    Debug.Log($"Hit: {hit.collider.name}");
}

// ✅ Multiple hits (non-allocating)
RaycastHit[] results = new RaycastHit[10];
int hitCount = Physics.RaycastNonAlloc(origin, direction, results, maxDistance);
for (int i = 0; i < hitCount; i++) {
    Debug.Log($"Hit {i}: {results[i].collider.name}");
}

// ❌ Avoid: RaycastAll (allocates array every call)
RaycastHit[] hits = Physics.RaycastAll(origin, direction); // GC allocation!
```

### 선택적 레이캐스팅을 위한 LayerMask

```csharp
// ✅ Use LayerMask to filter collisions
int layerMask = 1 << LayerMask.NameToLayer("Enemy");
Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance, layerMask);
```

---

## 물리 쿼리

### OverlapSphere (주변 오브젝트 확인)

```csharp
// ✅ Non-allocating version
Collider[] results = new Collider[10];
int count = Physics.OverlapSphereNonAlloc(center, radius, results);
for (int i = 0; i < count; i++) {
    // Process results[i]
}
```

### SphereCast (두꺼운 레이캐스트)

```csharp
// Useful for character controllers
if (Physics.SphereCast(origin, radius, direction, out RaycastHit hit, maxDistance)) {
    // Hit something with a sphere-shaped ray
}
```

---

## 충돌 이벤트

### OnCollisionEnter / Stay / Exit

```csharp
void OnCollisionEnter(Collision collision) {
    // Triggered when collision starts
    Debug.Log($"Collided with {collision.gameObject.name}");

    // Access contact points
    foreach (ContactPoint contact in collision.contacts) {
        Debug.DrawRay(contact.point, contact.normal, Color.red, 2f);
    }
}
```

### OnTriggerEnter / Stay / Exit

```csharp
void OnTriggerEnter(Collider other) {
    // Trigger collider (Is Trigger = true)
    if (other.CompareTag("Pickup")) {
        Destroy(other.gameObject);
    }
}
```

---

## 캐릭터 컨트롤러

### CharacterController 컴포넌트

```csharp
CharacterController controller = GetComponent<CharacterController>();

// ✅ Move with collision detection
Vector3 move = transform.forward * speed * Time.deltaTime;
controller.Move(move);

// Apply gravity manually
if (!controller.isGrounded) {
    velocity.y += Physics.gravity.y * Time.deltaTime;
}
controller.Move(velocity * Time.deltaTime);
```

---

## 물리 머티리얼

### 마찰 & 탄성

```csharp
// Create: Assets > Create > Physic Material
// Assign to collider: Collider > Material

// PhysicMaterial settings:
// - Dynamic Friction: 0.6 (sliding friction)
// - Static Friction: 0.6 (starting friction)
// - Bounciness: 0.0 - 1.0
// - Friction Combine: Average, Minimum, Maximum, Multiply
// - Bounce Combine: Average, Minimum, Maximum, Multiply
```

---

## 조인트

### Fixed Joint (두 리지드바디 연결)

```csharp
FixedJoint joint = gameObject.AddComponent<FixedJoint>();
joint.connectedBody = otherRigidbody;
```

### Hinge Joint (문, 바퀴)

```csharp
HingeJoint hinge = gameObject.AddComponent<HingeJoint>();
hinge.axis = Vector3.up; // Rotation axis
hinge.useLimits = true;
hinge.limits = new JointLimits { min = -90, max = 90 };
```

---

## 성능 최적화

### 물리 레이어 충돌 매트릭스
`Edit > Project Settings > Physics > Layer Collision Matrix`
- 레이어 간 불필요한 충돌 검사를 비활성화
- 성능이 크게 향상됨

### Fixed Timestep
`Edit > Project Settings > Time > Fixed Timestep`
- 기본값: 0.02 (50 FPS 물리)
- 낮을수록 정확하지만 CPU 비용이 높아짐
- 가능하면 게임의 목표 프레임레이트에 맞출 것

### 단순화된 충돌 지오메트리
- 메시 콜라이더 대신 기본 콜라이더(box, sphere, capsule) 사용
- 메시 콜라이더는 런타임이 아닌 빌드 타임에 베이크

---

## 자주 쓰이는 패턴

### 접지 확인 (Ground Check, 캐릭터 컨트롤러)

```csharp
bool IsGrounded() {
    float rayLength = 0.1f;
    return Physics.Raycast(transform.position, Vector3.down, rayLength);
}
```

### 폭발력 적용

```csharp
void ApplyExplosion(Vector3 explosionPos, float radius, float force) {
    Collider[] colliders = Physics.OverlapSphere(explosionPos, radius);
    foreach (Collider hit in colliders) {
        Rigidbody rb = hit.GetComponent<Rigidbody>();
        if (rb != null) {
            rb.AddExplosionForce(force, explosionPos, radius);
        }
    }
}
```

---

## 디버깅

### Physics Debugger (Unity 6+)
- `Window > Analysis > Physics Debugger`
- 콜라이더, 접촉점, 쿼리를 시각화

### Gizmos

```csharp
void OnDrawGizmos() {
    Gizmos.color = Color.red;
    Gizmos.DrawWireSphere(transform.position, detectionRadius);
}
```

---

## 출처
- https://docs.unity3d.com/6000.0/Documentation/Manual/PhysicsOverview.html
- https://docs.unity3d.com/ScriptReference/Physics.html
