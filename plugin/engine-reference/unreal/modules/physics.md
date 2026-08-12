# Unreal Engine 5.7 — 물리 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** UE 5.7 Chaos Physics 개선 사항

---

## 개요

UE 5는 **Chaos Physics**를 사용한다(UE 4의 PhysX를 대체):
- 더 나은 성능
- 파괴(Destruction) 지원
- 차량 물리 개선

---

## 강체 물리(Rigid Body Physics)

### Static Mesh에서 물리 활성화

```cpp
UStaticMeshComponent* MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
MeshComp->SetSimulatePhysics(true);
MeshComp->SetEnableGravity(true);
MeshComp->SetMassOverrideInKg(NAME_None, 50.0f); // 50 kg
```

### 힘 적용

```cpp
// 임펄스 적용(즉각적인 속도 변화)
MeshComp->AddImpulse(FVector(0, 0, 1000), NAME_None, true);

// 힘 적용(지속적인 힘)
MeshComp->AddForce(FVector(0, 0, 500));

// 토크 적용(회전)
MeshComp->AddTorqueInRadians(FVector(0, 0, 100));
```

---

## 충돌(Collision)

### 충돌 채널

```cpp
// Project Settings > Engine > Collision
// 커스텀 충돌 채널과 응답을 정의

// C++에서 충돌 설정
MeshComp->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
MeshComp->SetCollisionObjectType(ECollisionChannel::ECC_Pawn);
MeshComp->SetCollisionResponseToAllChannels(ECR_Block);
MeshComp->SetCollisionResponseToChannel(ECC_Camera, ECR_Ignore);
```

### 충돌 이벤트

```cpp
// 충돌 이벤트 활성화
MeshComp->SetNotifyRigidBodyCollision(true);

// OnComponentHit에 바인딩
MeshComp->OnComponentHit.AddDynamic(this, &AMyActor::OnHit);

UFUNCTION()
void AMyActor::OnHit(UPrimitiveComponent* HitComp, AActor* OtherActor,
    UPrimitiveComponent* OtherComp, FVector NormalImpulse, const FHitResult& Hit) {
    UE_LOG(LogTemp, Warning, TEXT("Hit %s"), *OtherActor->GetName());
}
```

### 오버랩 이벤트

```cpp
// 오버랩 이벤트 활성화
MeshComp->SetGenerateOverlapEvents(true);

// OnComponentBeginOverlap에 바인딩
MeshComp->OnComponentBeginOverlap.AddDynamic(this, &AMyActor::OnOverlapBegin);

UFUNCTION()
void AMyActor::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor,
    UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult) {
    UE_LOG(LogTemp, Warning, TEXT("Overlapped %s"), *OtherActor->GetName());
}
```

---

## 레이캐스팅(라인 트레이스)

### 단일 라인 트레이스

```cpp
FHitResult HitResult;
FVector Start = GetActorLocation();
FVector End = Start + GetActorForwardVector() * 1000.0f;

FCollisionQueryParams QueryParams;
QueryParams.AddIgnoredActor(this);

// 트레이스 수행
bool bHit = GetWorld()->LineTraceSingleByChannel(
    HitResult,
    Start,
    End,
    ECC_Visibility,
    QueryParams
);

if (bHit) {
    UE_LOG(LogTemp, Warning, TEXT("Hit: %s"), *HitResult.GetActor()->GetName());
    DrawDebugLine(GetWorld(), Start, HitResult.Location, FColor::Red, false, 2.0f);
}
```

### 멀티 라인 트레이스

```cpp
TArray<FHitResult> HitResults;
bool bHit = GetWorld()->LineTraceMultiByChannel(
    HitResults,
    Start,
    End,
    ECC_Visibility,
    QueryParams
);

for (const FHitResult& Hit : HitResults) {
    UE_LOG(LogTemp, Warning, TEXT("Hit: %s"), *Hit.GetActor()->GetName());
}
```

### 스윕(두꺼운 트레이스)

```cpp
FHitResult HitResult;
FCollisionShape Sphere = FCollisionShape::MakeSphere(50.0f);

bool bHit = GetWorld()->SweepSingleByChannel(
    HitResult,
    Start,
    End,
    FQuat::Identity,
    ECC_Visibility,
    Sphere,
    QueryParams
);
```

---

## 캐릭터 이동(Character Movement)

### Character Movement Component

```cpp
// ACharacter 클래스에 내장되어 있음
UCharacterMovementComponent* MoveComp = GetCharacterMovement();

// 이동 설정
MoveComp->MaxWalkSpeed = 600.0f;
MoveComp->JumpZVelocity = 600.0f;
MoveComp->AirControl = 0.2f;
MoveComp->GravityScale = 1.0f;
MoveComp->bOrientRotationToMovement = true;
```

### 이동 입력 추가

```cpp
// Character 클래스 내부
void AMyCharacter::MoveForward(float Value) {
    if (Value != 0.0f) {
        AddMovementInput(GetActorForwardVector(), Value);
    }
}

void AMyCharacter::MoveRight(float Value) {
    if (Value != 0.0f) {
        AddMovementInput(GetActorRightVector(), Value);
    }
}
```

---

## 물리 머티리얼(Physical Materials)

### 물리 머티리얼 생성

1. 콘텐츠 브라우저 > 우클릭 > Physics > Physical Material
2. 속성 설정:
   - Friction(마찰): 0.0 - 1.0
   - Restitution(반발력/탄성): 0.0 - 1.0

### 물리 머티리얼 할당

```cpp
// Static Mesh 에디터에서: Physics > Phys Material Override
// 또는 C++에서:
MeshComp->SetPhysMaterialOverride(PhysicalMaterial);
```

---

## 제약(Constraints, 물리 조인트)

### Physics Constraint Component

```cpp
UPhysicsConstraintComponent* Constraint = CreateDefaultSubobject<UPhysicsConstraintComponent>(TEXT("Constraint"));
Constraint->SetConstrainedComponents(ComponentA, NAME_None, ComponentB, NAME_None);

// 제약 설정
Constraint->SetLinearXLimit(ELinearConstraintMotion::LCM_Limited, 100.0f);
Constraint->SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
Constraint->SetLinearZLimit(ELinearConstraintMotion::LCM_Free, 0.0f);

Constraint->SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Limited, 45.0f);
```

---

## 파괴(Chaos Destruction)

### Chaos Destruction 활성화

```cpp
// 플러그인: "Chaos" 플러그인 활성화
// 파괴 가능한 오브젝트용으로 Geometry Collection 애셋을 생성
```

### Geometry Collection 파괴

```cpp
// Chaos 에디터에서 메시를 파쇄(fracture)
// 게임 내에서 데미지 적용:
UGeometryCollectionComponent* GeoComp = /* 컴포넌트 획득 */;
GeoComp->ApplyPhysicsField(/* 필드 파라미터 */);
```

---

## 성능 팁

### 물리 최적화

```cpp
// 충돌 형상을 단순화(단순한 프리미티브 사용)
MeshComp->SetCollisionEnabled(ECollisionEnabled::NoCollision); // 필요하지 않을 때는 비활성화

// 스켈레탈 메시에는 Physics Asset을 사용(단순화된 충돌)
// 멀리 있는 오브젝트에는 물리 시뮬레이션을 하지 않음

// 물리 서브스텝 줄이기:
// Project Settings > Engine > Physics > Max Substep Delta Time
```

---

## 디버깅

### 물리 디버그 시각화

```cpp
// 콘솔 명령어:
// show collision - 충돌 형상 표시
// p.Chaos.DebugDraw.Enabled 1 - Chaos 디버그 표시
// pxvis collision - 충돌 시각화

// 디버그 형상 그리기:
DrawDebugSphere(GetWorld(), Location, Radius, 12, FColor::Green, false, 2.0f);
DrawDebugBox(GetWorld(), Location, Extent, FColor::Red, false, 2.0f);
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/physics-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/chaos-physics-overview-in-unreal-engine/
