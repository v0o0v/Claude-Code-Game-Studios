# Unity 6.3 — 애니메이션 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** Unity 6 애니메이션 개선 사항, Timeline 기능 강화

---

## 개요

Unity 6.3 애니메이션 시스템:
- **Animator Controller (Mecanim)**: 상태 머신 기반 (권장)
- **Timeline**: 시네마틱 시퀀스, 컷신
- **Animation Rigging**: 런타임 프로시저럴 애니메이션
- **Legacy Animation**: 지원 중단, 사용 지양

---

## 2022 LTS 대비 주요 변경 사항

### Animation Rigging 패키지 (Unity 6에서 프로덕션 준비 완료)

```csharp
// Install: Package Manager > Animation Rigging
// Runtime IK, aim constraints, procedural animation
```

### Timeline 개선 사항
- 성능 향상
- 트랙 타입 추가
- 시그널 시스템 개선

---

## Animator Controller (Mecanim)

### 기본 설정

```csharp
// Create: Assets > Create > Animator Controller
// Add to GameObject: Add Component > Animator
// Assign Controller: Animator > Controller = YourAnimatorController
```

### 상태 전환

```csharp
Animator animator = GetComponent<Animator>();

// ✅ 트리거 전환
animator.SetTrigger("Jump");

// ✅ Bool 파라미터
animator.SetBool("IsRunning", true);

// ✅ Float 파라미터 (블렌드 트리)
animator.SetFloat("Speed", currentSpeed);

// ✅ Integer 파라미터
animator.SetInteger("WeaponType", 2);
```

### 애니메이션 레이어
- **Base Layer**: 기본 애니메이션(로코모션)
- **Override Layers**: 베이스 레이어를 대체(예: 무기 교체)
- **Additive Layers**: 베이스 레이어 위에 가산(예: 호흡, 조준 오프셋)

```csharp
// 레이어 가중치 설정 (0-1)
animator.SetLayerWeight(1, 0.5f); // 50% 블렌드
```

---

## 블렌드 트리

### 1D 블렌드 트리 (속도 블렌딩)

```csharp
// Idle (Speed = 0) → Walk (Speed = 0.5) → Run (Speed = 1.0)
animator.SetFloat("Speed", moveSpeed);
```

### 2D 블렌드 트리 (방향성 이동)

```csharp
// X축: Strafe (-1 to 1)
// Y축: Forward/Back (-1 to 1)
animator.SetFloat("MoveX", input.x);
animator.SetFloat("MoveY", input.y);
```

---

## 애니메이션 이벤트

### 애니메이션 클립에서 이벤트 트리거

```csharp
// Add in Animation window: Right-click timeline > Add Animation Event
// Must have matching method on GameObject:

public void OnFootstep() {
    // 발소리 재생
    AudioSource.PlayClipAtPoint(footstepClip, transform.position);
}

public void OnAttackHit() {
    // 데미지 처리
    DealDamageInFrontOfPlayer();
}
```

---

## Root Motion

### 애니메이션을 통한 캐릭터 이동

```csharp
Animator animator = GetComponent<Animator>();
animator.applyRootMotion = true; // 애니메이션 기반으로 캐릭터 이동

void OnAnimatorMove() {
    // 커스텀 root motion 처리
    transform.position += animator.deltaPosition;
    transform.rotation *= animator.deltaRotation;
}
```

---

## Animation Rigging (Unity 6+)

### IK (역운동학)

```csharp
// Install: Package Manager > Animation Rigging
// Add: Rig Builder component + Rig GameObject

// Two Bone IK (팔/다리)
// - Add Two Bone IK Constraint
// - Assign Tip (hand/foot), Mid (elbow/knee), Root (shoulder/hip)
// - Set Target (where hand/foot should reach)

// 런타임 제어:
TwoBoneIKConstraint ikConstraint = rig.GetComponentInChildren<TwoBoneIKConstraint>();
ikConstraint.data.target = targetTransform;
ikConstraint.weight = 1f; // 0-1 블렌드
```

### Aim Constraint (시선 처리)

```csharp
// 캐릭터가 타겟을 바라보게 함
MultiAimConstraint aimConstraint = rig.GetComponentInChildren<MultiAimConstraint>();
aimConstraint.data.sourceObjects[0] = new WeightedTransform(targetTransform, 1f);
```

---

## Timeline (컷신)

### 기본 Timeline 설정

```csharp
// Create: Assets > Create > Timeline
// Add to GameObject: Add Component > Playable Director
// Assign Timeline: Playable Director > Playable = YourTimeline

// 스크립트에서 재생:
PlayableDirector director = GetComponent<PlayableDirector>();
director.Play();
```

### Timeline 트랙
- **Activation Track**: GameObject 활성화/비활성화
- **Animation Track**: Animator에서 애니메이션 재생
- **Audio Track**: 동기화된 오디오 재생
- **Cinemachine Track**: 카메라 움직임
- **Signal Track**: 특정 시점에 이벤트 트리거

### 시그널 시스템 (이벤트)

```csharp
// Create Signal Asset: Assets > Create > Signals > Signal
// Add Signal Emitter to Timeline track
// Add Signal Receiver component to GameObject

public class CutsceneEvents : MonoBehaviour {
    public void OnDialogueStart() {
        // 시그널에 의해 트리거됨
    }
}
```

---

## 애니메이션 재생 제어

### 상태 머신 없이 애니메이션 직접 재생

```csharp
// ✅ CrossFade (부드러운 전환)
animator.CrossFade("Attack", 0.2f); // 0.2초 전환

// ✅ Play (즉시 재생)
animator.Play("Idle");

// ❌ 피할 것: Legacy Animation 컴포넌트
Animation anim = GetComponent<Animation>(); // 지원 중단(DEPRECATED)
```

---

## 애니메이션 커브

### 커스텀 프로퍼티 애니메이션

```csharp
// In Animation window: Add Property > Custom Component > Your Script > Your Float

public class WeaponTrail : MonoBehaviour {
    public float trailIntensity; // 클립에 의해 애니메이션됨

    void Update() {
        // 애니메이션 커브로 제어되는 강도
        trailRenderer.startWidth = trailIntensity;
    }
}
```

---

## 성능 최적화

### 컬링

- `Animator > Culling Mode`:
  - **Always Animate**: 항상 업데이트(비용이 큼)
  - **Cull Update Transforms**: 화면 밖일 때 본 업데이트 중단(권장)
  - **Cull Completely**: 화면 밖일 때 애니메이션 전체 중단

### LOD (Level of Detail)

- 멀리 있는 캐릭터에는 단순한 애니메이션 사용
- LOD 메시에서는 스켈레톤 본 개수 감소

---

## 자주 쓰이는 패턴

### 애니메이션 종료 여부 확인

```csharp
AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
if (stateInfo.IsName("Attack") && stateInfo.normalizedTime >= 1.0f) {
    // 공격 애니메이션 종료됨
}
```

### 애니메이션 속도 오버라이드

```csharp
animator.speed = 1.5f; // 150% 속도
```

### 현재 애니메이션 이름 가져오기

```csharp
AnimatorClipInfo[] clipInfo = animator.GetCurrentAnimatorClipInfo(0);
string currentClip = clipInfo[0].clip.name;
```

---

## 디버깅

### Animator 창

- `Window > Animation > Animator`
- 상태 머신 시각화, 활성 상태 확인

### Animation 창

- `Window > Animation > Animation`
- 애니메이션 클립 편집, 이벤트 추가

---

## 출처
- https://docs.unity3d.com/6000.0/Documentation/Manual/AnimationOverview.html
- https://docs.unity3d.com/Packages/com.unity.animation.rigging@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.timeline@1.8/manual/index.html
