# Unreal Engine 5.7 — 오디오 모듈 레퍼런스

**최종 검증일:** 2026-02-13
**지식 공백:** UE 5.7 MetaSounds 프로덕션 준비 완료

---

## 개요

UE 5.7 오디오 시스템:
- **MetaSounds**: 노드 기반 프로시저럴 오디오(권장, 프로덕션 준비 완료)
- **Sound Cues**: 레거시 노드 기반 오디오(단순한 경우에 사용)
- **Audio Component**: 액터에서 사운드 재생

---

## 기본 오디오 재생

### 위치에서 사운드 재생

```cpp
#include "Kismet/GameplayStatics.h"

// ✅ Play 2D sound (no spatialization)
UGameplayStatics::PlaySound2D(GetWorld(), ExplosionSound);

// ✅ Play sound at location (3D spatial audio)
UGameplayStatics::PlaySoundAtLocation(GetWorld(), ExplosionSound, GetActorLocation());

// ✅ With volume and pitch
UGameplayStatics::PlaySoundAtLocation(GetWorld(), ExplosionSound, GetActorLocation(), 0.7f, 1.2f);
```

---

## Audio Component

### Audio Component (지속형 사운드)

```cpp
// Create audio component
UAudioComponent* AudioComp = CreateDefaultSubobject<UAudioComponent>(TEXT("Audio"));
AudioComp->SetupAttachment(RootComponent);
AudioComp->SetSound(LoopingAmbience);

// Play/Stop
AudioComp->Play();
AudioComp->Stop();

// Fade in/out
AudioComp->FadeIn(2.0f); // 2 seconds
AudioComp->FadeOut(1.5f, 0.0f); // 1.5s to volume 0

// Adjust volume/pitch
AudioComp->SetVolumeMultiplier(0.5f);
AudioComp->SetPitchMultiplier(1.2f);
```

---

## 3D 공간 오디오

### Attenuation 설정

```cpp
// Create Sound Attenuation asset:
// Content Browser > Sounds > Sound Attenuation

// Configure:
// - Attenuation Shape: Sphere, Capsule, Box, Cone
// - Falloff Distance: Distance where sound becomes inaudible
// - Attenuation Function: Linear, Logarithmic, Inverse, etc.

// Assign in C++:
AudioComp->AttenuationSettings = AttenuationAsset;
```

### 코드에서 Attenuation 오버라이드

```cpp
FSoundAttenuationSettings AttenuationOverride;
AttenuationOverride.AttenuationShape = EAttenuationShape::Sphere;
AttenuationOverride.FalloffDistance = 1000.0f;
AttenuationOverride.AttenuationShapeExtents = FVector(1000.0f);

AudioComp->AttenuationOverrides = AttenuationOverride;
AudioComp->bOverrideAttenuation = true;
```

---

## MetaSounds (프로시저럴 오디오)

### MetaSound Source 생성

1. Content Browser > Sounds > MetaSound Source
2. MetaSound 에디터 열기
3. 노드 그래프 구성:
   - **Inputs**: 트리거, 파라미터
   - **Generators**: 오실레이터, 노이즈, 샘플
   - **Modulators**: 엔벨로프, LFO
   - **Effects**: 필터, 리버브, 딜레이
   - **Output**: 오디오 출력

### MetaSound 재생

```cpp
// Play MetaSound like any sound
UGameplayStatics::PlaySound2D(GetWorld(), MetaSoundSource);

// Or with Audio Component
AudioComp->SetSound(MetaSoundSource);
AudioComp->Play();
```

### MetaSound 파라미터 설정

```cpp
// Define parameter in MetaSound (Input node with exposed parameter)
// Set parameter in C++:
AudioComp->SetFloatParameter(FName("Volume"), 0.8f);
AudioComp->SetIntParameter(FName("OctaveShift"), 2);
AudioComp->SetBoolParameter(FName("EnableReverb"), true);
```

---

## Sound Cue (레거시)

### Sound Cue 생성

1. Content Browser > Sounds > Sound Cue
2. Sound Cue 에디터 열기
3. 노드 추가: Random, Modulator, Mixer 등

### Sound Cue 사용

```cpp
// Play like any sound
UGameplayStatics::PlaySound2D(GetWorld(), SoundCue);
```

---

## Sound Class & Sound Mix

### Sound Class (볼륨 그룹)

```cpp
// Create Sound Class: Content Browser > Sounds > Sound Class
// Hierarchy: Master > Music, SFX, Dialogue

// Assign to sound asset:
// Sound Wave > Sound Class = SFX

// Set volume in C++:
UAudioSettings* AudioSettings = GetMutableDefault<UAudioSettings>();
// Configure via Sound Class hierarchy
```

### Sound Mix (동적 믹싱)

```cpp
// Create Sound Mix asset
// Define adjustments: Lower music during dialogue, etc.

// Push sound mix
UGameplayStatics::PushSoundMixModifier(GetWorld(), DuckedMusicMix);

// Pop sound mix
UGameplayStatics::PopSoundMixModifier(GetWorld(), DuckedMusicMix);
```

---

## 오디오 오클루전 & 리버브

### 오디오 오클루전 (벽이 사운드를 차단)

```cpp
// Enable in Audio Component:
AudioComp->bEnableOcclusion = true;

// Requires geometry with collision
```

### Reverb Volume

```cpp
// Add Audio Volume to level (Volumes > Audio Volume)
// Configure reverb settings in Details panel
// Audio component automatically picks up reverb when inside volume
```

---

## 일반적인 패턴

### 발소리 (랜덤 변형)

```cpp
// Use Sound Cue with Random node, or:
UPROPERTY(EditAnywhere, Category = "Audio")
TArray<TObjectPtr<USoundBase>> FootstepSounds;

void PlayFootstep() {
    int32 Index = FMath::RandRange(0, FootstepSounds.Num() - 1);
    UGameplayStatics::PlaySoundAtLocation(GetWorld(), FootstepSounds[Index], GetActorLocation());
}
```

### 음악 크로스페이드

```cpp
UAudioComponent* MusicA;
UAudioComponent* MusicB;

void CrossfadeMusic(float Duration) {
    MusicA->FadeOut(Duration, 0.0f);
    MusicB->FadeIn(Duration);
}
```

### 사운드 재생 여부 확인

```cpp
if (AudioComp->IsPlaying()) {
    // Sound is playing
}
```

---

## Audio Concurrency

### 동시 재생 사운드 수 제한

```cpp
// Create Sound Concurrency asset:
// Content Browser > Sounds > Sound Concurrency

// Configure:
// - Max Count: Maximum instances of this sound
// - Resolution Rule: Stop Oldest, Stop Quietest, etc.

// Assign to sound:
// Sound Wave > Concurrency Settings
```

---

## 성능 팁

### 오디오 최적화

```cpp
// Compression settings (Sound Wave asset):
// - Compression Quality: 40 (balance quality/size)
// - Streaming: Enable for large files (music)

// Reduce audio mixing cost:
// - Limit concurrent sounds via Sound Concurrency
// - Use simple attenuation shapes

// Disable audio for distant actors:
if (Distance > MaxAudibleDistance) {
    AudioComp->Stop();
}
```

---

## 디버깅

### 오디오 디버그 명령

```cpp
// Console commands:
// au.Debug.Sounds 1 - Show active sounds
// au.3dVisualize.Enabled 1 - Visualize 3D audio
// stat soundwaves - Show sound statistics
// stat soundmixes - Show active sound mixes
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/audio-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/metasounds-in-unreal-engine/
