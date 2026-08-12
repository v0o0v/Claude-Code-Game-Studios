# Unreal Engine 5.7 — 네트워킹 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** UE 5.7 네트워킹 개선 사항

---

## 개요

UE 5.7 네트워킹:
- **클라이언트-서버 아키텍처**: 서버 권위(Server-Authoritative) 방식 (권장)
- **Replication**: 자동 상태 동기화
- **RPC(원격 프로시저 호출)**: 네트워크를 통해 함수를 호출
- **Relevancy**: 관련 있는 액터만 복제하여 대역폭을 최적화

---

## 기본 멀티플레이어 설정

### 액터에서 Replication 활성화

```cpp
UCLASS()
class AMyActor : public AActor {
    GENERATED_BODY()

public:
    AMyActor() {
        // ✅ Replication 활성화
        bReplicates = true;
        bAlwaysRelevant = true; // 모든 클라이언트에 항상 복제
    }
};
```

### 네트워크 Role 확인

```cpp
// Role 확인
if (HasAuthority()) {
    // 서버에서 실행 중
}

if (GetLocalRole() == ROLE_AutonomousProxy) {
    // 이 인스턴스는 소유 중인 클라이언트(로컬 플레이어)임
}

if (GetRemoteRole() == ROLE_SimulatedProxy) {
    // 이 인스턴스는 원격 클라이언트(다른 플레이어)임
}
```

---

## 복제되는 변수(Replicated Variables)

### 기본 Replication

```cpp
UPROPERTY(Replicated)
int32 Health;

UPROPERTY(Replicated)
FVector Position;

// ✅ GetLifetimeReplicatedProps 구현
void AMyActor::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);

    DOREPLIFETIME(AMyActor, Health);
    DOREPLIFETIME(AMyActor, Position);
}
```

### 조건부 Replication

```cpp
// 소유자에게만 복제
DOREPLIFETIME_CONDITION(AMyCharacter, Ammo, COND_OwnerOnly);

// 소유자를 제외하고 복제(나머지 전원에게 복제)
DOREPLIFETIME_CONDITION(AMyCharacter, TeamID, COND_SkipOwner);

// 변경되었을 때만 복제
DOREPLIFETIME_CONDITION(AMyCharacter, Score, COND_InitialOnly);
```

### RepNotify(Replication 발생 시 콜백)

```cpp
UPROPERTY(ReplicatedUsing=OnRep_Health)
int32 Health;

UFUNCTION()
void OnRep_Health() {
    // Health가 변경될 때 클라이언트에서 호출됨
    UpdateHealthUI();
}

// GetLifetimeReplicatedProps 구현(위와 동일)
```

---

## RPC(원격 프로시저 호출)

### Server RPC(클라이언트 → 서버)

```cpp
// 클라이언트가 호출하고, 서버가 실행
UFUNCTION(Server, Reliable)
void Server_TakeDamage(int32 Damage);

void AMyCharacter::Server_TakeDamage_Implementation(int32 Damage) {
    // 서버에서만 실행됨
    Health -= Damage;

    if (Health <= 0) {
        Server_Die();
    }
}

bool AMyCharacter::Server_TakeDamage_Validate(int32 Damage) {
    // 입력값 검증(치트 방지)
    return Damage >= 0 && Damage <= 100;
}
```

### Client RPC(서버 → 클라이언트)

```cpp
// 서버가 호출하고, 클라이언트가 실행
UFUNCTION(Client, Reliable)
void Client_ShowDeathScreen();

void AMyCharacter::Client_ShowDeathScreen_Implementation() {
    // 클라이언트에서만 실행됨
    ShowDeathUI();
}
```

### Multicast RPC(서버 → 모든 클라이언트)

```cpp
// 서버가 호출하고, 모든 클라이언트가 실행
UFUNCTION(NetMulticast, Reliable)
void Multicast_PlayExplosion(FVector Location);

void AMyActor::Multicast_PlayExplosion_Implementation(FVector Location) {
    // 서버와 모든 클라이언트에서 실행됨
    UGameplayStatics::SpawnEmitterAtLocation(GetWorld(), ExplosionEffect, Location);
}
```

### RPC 신뢰성(Reliability)

```cpp
// Reliable: 전달을 보장(중요한 이벤트용)
UFUNCTION(Server, Reliable)
void Server_FireWeapon();

// Unreliable: 최선 노력 전달(빈번한 업데이트, 위치 동기화용)
UFUNCTION(Server, Unreliable)
void Server_UpdateAim(FRotator AimRotation);
```

---

## 서버 권위 패턴(RECOMMENDED)

### 이동(Movement) 예시

```cpp
class AMyCharacter : public ACharacter {
    UPROPERTY(Replicated)
    FVector ServerPosition;

    void Tick(float DeltaTime) override {
        Super::Tick(DeltaTime);

        if (GetLocalRole() == ROLE_AutonomousProxy) {
            // 클라이언트: 입력을 서버로 전송
            FVector Input = GetMovementInput();
            Server_Move(Input);

            // 클라이언트 사이드 예측(로컬에서 먼저 이동)
            AddMovementInput(Input);
        }

        if (HasAuthority()) {
            // 서버: 권위 있는 위치
            ServerPosition = GetActorLocation();
        } else {
            // 클라이언트: 서버 위치를 향해 보간
            FVector NewPos = FMath::VInterpTo(GetActorLocation(), ServerPosition, DeltaTime, 5.0f);
            SetActorLocation(NewPos);
        }
    }

    UFUNCTION(Server, Unreliable)
    void Server_Move(FVector Input);

    void Server_Move_Implementation(FVector Input) {
        // 서버가 이동을 검증하고 적용
        AddMovementInput(Input);
    }
};
```

---

## 네트워크 Relevancy(대역폭 최적화)

### 커스텀 Relevancy

```cpp
bool AMyActor::IsNetRelevantFor(const AActor* RealViewer, const AActor* ViewTarget, const FVector& SrcLocation) const {
    // 범위 내에 있을 때만 복제
    float Distance = FVector::Dist(SrcLocation, GetActorLocation());
    return Distance < 5000.0f;
}
```

### 항상 관련 있는(Always Relevant) 액터

```cpp
AMyActor() {
    bAlwaysRelevant = true; // 모든 클라이언트에 복제(예: GameState, PlayerController)
    bOnlyRelevantToOwner = true; // 소유자에게만 복제(예: PlayerController)
}
```

---

## 소유권(Ownership)

### 소유자 설정

```cpp
// 소유자 지정(RPC와 relevancy에 중요함)
MyActor->SetOwner(OwningPlayerController);
```

### 소유자 확인

```cpp
if (GetOwner() == PlayerController) {
    // 이 액터는 이 플레이어가 소유하고 있음
}
```

---

## Game Mode & Game State

### Game Mode(서버 전용)

```cpp
UCLASS()
class AMyGameMode : public AGameMode {
    GENERATED_BODY()

public:
    // Game Mode는 서버에만 존재함
    // 서버 사이드 로직(스폰, 스코어링, 규칙)에 사용
};
```

### Game State(모든 클라이언트에 복제됨)

```cpp
UCLASS()
class AMyGameState : public AGameState {
    GENERATED_BODY()

public:
    // ✅ Game State를 모든 클라이언트에 복제
    UPROPERTY(Replicated)
    int32 RedTeamScore;

    UPROPERTY(Replicated)
    int32 BlueTeamScore;

    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override {
        Super::GetLifetimeReplicatedProps(OutLifetimeProps);
        DOREPLIFETIME(AMyGameState, RedTeamScore);
        DOREPLIFETIME(AMyGameState, BlueTeamScore);
    }
};
```

---

## Player Controller & Player State

### Player Controller(플레이어당 하나)

```cpp
UCLASS()
class AMyPlayerController : public APlayerController {
    GENERATED_BODY()

public:
    // 서버와 소유 중인 클라이언트에 존재함
    // 플레이어별 로직, 입력 처리에 사용
};
```

### Player State(복제되는 플레이어 정보)

```cpp
UCLASS()
class AMyPlayerState : public APlayerState {
    GENERATED_BODY()

public:
    UPROPERTY(Replicated)
    int32 Kills;

    UPROPERTY(Replicated)
    int32 Deaths;

    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override {
        Super::GetLifetimeReplicatedProps(OutLifetimeProps);
        DOREPLIFETIME(AMyPlayerState, Kills);
        DOREPLIFETIME(AMyPlayerState, Deaths);
    }
};
```

---

## 세션 & 매치메이킹

### 세션 생성

```cpp
#include "OnlineSubsystem.h"
#include "OnlineSessionSettings.h"

void CreateSession() {
    IOnlineSubsystem* OnlineSub = IOnlineSubsystem::Get();
    IOnlineSessionPtr Sessions = OnlineSub->GetSessionInterface();

    TSharedPtr<FOnlineSessionSettings> SessionSettings = MakeShareable(new FOnlineSessionSettings());
    SessionSettings->bIsLANMatch = false;
    SessionSettings->NumPublicConnections = 4;
    SessionSettings->bShouldAdvertise = true;

    Sessions->CreateSession(0, FName("MySession"), *SessionSettings);
}
```

### 세션 찾기

```cpp
void FindSessions() {
    IOnlineSubsystem* OnlineSub = IOnlineSubsystem::Get();
    IOnlineSessionPtr Sessions = OnlineSub->GetSessionInterface();

    TSharedRef<FOnlineSessionSearch> SearchSettings = MakeShareable(new FOnlineSessionSearch());
    SearchSettings->bIsLanQuery = false;
    SearchSettings->MaxSearchResults = 20;

    Sessions->FindSessions(0, SearchSettings);
}
```

---

## 성능 팁

### 대역폭 줄이기

```cpp
// 빈번한 업데이트에는 unreliable RPC 사용
UFUNCTION(Server, Unreliable)
void Server_UpdatePosition(FVector Pos);

// 조건부 복제(관련 있는 클라이언트에만 복제)
DOREPLIFETIME_CONDITION(AMyActor, Health, COND_OwnerOnly);

// 복제 빈도 제한
SetReplicationFrequency(10.0f); // 초당 10회 업데이트(기본값 100)
```

---

## 디버깅

### 네트워크 디버깅

```cpp
// 콘솔 명령어:
// stat net - 네트워크 통계 표시
// stat netplayerupdate - 플레이어 업데이트 통계 표시
// NetEmulation PktLoss=10 - 10% 패킷 손실 시뮬레이션
// NetEmulation PktLag=100 - 100ms 지연 시뮬레이션

// Replication 디버그 출력:
UE_LOG(LogNet, Warning, TEXT("Replicating Health: %d"), Health);
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/networking-and-multiplayer-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/actor-replication-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/rpcs-in-unreal-engine/
