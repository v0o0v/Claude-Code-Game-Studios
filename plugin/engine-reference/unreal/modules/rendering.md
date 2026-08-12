# Unreal Engine 5.7 — 렌더링 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** UE 5.7에는 Megalights, 프로덕션 준비 완료된 Substrate, Lumen 개선 사항이 포함됨

---

## 개요

UE 5.7 렌더링 스택:
- **Lumen**: 실시간 전역 조명(글로벌 일루미네이션, 기본값)
- **Nanite**: 수백만 개의 삼각형을 위한 가상화 지오메트리
- **Megalights**: 수백만 개의 동적 라이트 지원(5.5+ 신규)
- **Substrate**: 프로덕션 준비가 완료된 모듈형 머티리얼 시스템(5.7 신규)

---

## Lumen(전역 조명)

### Lumen 활성화

```cpp
// Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// 실시간 GI, 라이트맵 베이킹이 필요 없음
```

### Lumen 품질 설정

```ini
; DefaultEngine.ini
[/Script/Engine.RendererSettings]
r.Lumen.DiffuseColorBoost=1.0
r.Lumen.ScreenProbeGather.RadianceCache.NumFramesToKeepCached=2
```

### C++에서 Lumen

```cpp
// Lumen이 활성화되어 있는지 확인
bool bIsLumenEnabled = IConsoleManager::Get().FindConsoleVariable(TEXT("r.DynamicGlobalIlluminationMethod"))->GetInt() == 1;
```

---

## Nanite(가상화 지오메트리)

### Static Mesh에서 Nanite 활성화

1. Static Mesh 에디터
2. Details > Nanite Settings > Enable Nanite Support
3. 메시 저장(Nanite 데이터가 자동으로 빌드됨)

### C++에서 Nanite

```cpp
// Nanite 메시 스폰
UStaticMeshComponent* MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
MeshComp->SetStaticMesh(NaniteMesh); // 활성화되어 있으면 자동으로 Nanite를 사용함
```

### Nanite의 제약 사항
- 버텍스 애니메이션(스켈레탈 메시) 불가
- 머티리얼에서 월드 포지션 오프셋(WPO) 불가
- 정적이고 폴리곤 수가 많은 지오메트리에 최적

---

## Megalights(UE 5.5+)

### Megalights 활성화

```cpp
// Project Settings > Engine > Rendering > Megalights = Enabled
// 최소한의 성능 비용으로 수백만 개의 동적 라이트를 지원함
```

### Megalights 사용법

```cpp
// 평소처럼 포인트 라이트를 추가
UPointLightComponent* Light = CreateDefaultSubobject<UPointLightComponent>(TEXT("Light"));
Light->SetIntensity(5000.0f);
Light->SetAttenuationRadius(500.0f);

// Megalights가 수천/수백만 개의 라이트를 자동으로 처리함
```

---

## Substrate 머티리얼(5.7에서 프로덕션 준비 완료)

### Substrate 활성화

```cpp
// Project Settings > Engine > Substrate > Enable Substrate
// 에디터 재시작
```

### Substrate 머티리얼 노드
- **Substrate Slab**: 물리 기반 머티리얼 레이어(디퓨즈, 스펙큘러 등)
- **Substrate Blend**: 여러 레이어를 블렌드
- **Substrate Thin Film**: 이리데선스(무지갯빛), 비눗방울 효과
- **Substrate Hair**: 헤어 전용 셰이딩

### Substrate 머티리얼 그래프 예시

```
Substrate Slab (Diffuse)
  └─ Base Color: Texture Sample
  └─ Roughness: Constant (0.5)
  └─ Metallic: Constant (0.0)
  └─ Connect to Material Output
```

---

## 머티리얼(C++ API)

### 동적 머티리얼 인스턴스

```cpp
// 동적 머티리얼 인스턴스 생성
UMaterialInstanceDynamic* DynMat = UMaterialInstanceDynamic::Create(BaseMaterial, this);

// 파라미터 설정
DynMat->SetVectorParameterValue(TEXT("BaseColor"), FLinearColor::Red);
DynMat->SetScalarParameterValue(TEXT("Metallic"), 0.8f);
DynMat->SetTextureParameterValue(TEXT("DiffuseTexture"), MyTexture);

// 메시에 적용
MeshComp->SetMaterial(0, DynMat);
```

---

## 포스트 프로세싱

### Post-Process Volume

```cpp
// 레벨에 추가
APostProcessVolume* PPV = GetWorld()->SpawnActor<APostProcessVolume>();
PPV->bUnbound = true; // 월드 전체에 영향을 줌

// 설정 구성
PPV->Settings.bOverride_MotionBlurAmount = true;
PPV->Settings.MotionBlurAmount = 0.5f;

PPV->Settings.bOverride_BloomIntensity = true;
PPV->Settings.BloomIntensity = 1.0f;
```

### C++에서 포스트 프로세스

```cpp
// 카메라의 포스트 프로세스 설정에 접근
APlayerController* PC = GetWorld()->GetFirstPlayerController();
if (APlayerCameraManager* CamManager = PC->PlayerCameraManager) {
    CamManager->PostProcessBlendWeight = 1.0f;
    CamManager->PostProcessSettings.BloomIntensity = 2.0f;
}
```

---

## 라이팅

### Directional Light(태양광)

```cpp
ADirectionalLight* Sun = GetWorld()->SpawnActor<ADirectionalLight>();
Sun->SetActorRotation(FRotator(-45.f, 0.f, 0.f));
Sun->GetLightComponent()->SetIntensity(10.0f);
Sun->GetLightComponent()->bCastShadows = true;
```

### Point Light

```cpp
APointLight* Light = GetWorld()->SpawnActor<APointLight>();
Light->SetActorLocation(FVector(0, 0, 200));
Light->GetPointLightComponent()->SetIntensity(5000.0f);
Light->GetPointLightComponent()->SetAttenuationRadius(1000.0f);
Light->GetPointLightComponent()->SetLightColor(FLinearColor::Red);
```

### Spot Light

```cpp
ASpotLight* Spotlight = GetWorld()->SpawnActor<ASpotLight>();
Spotlight->GetSpotLightComponent()->SetInnerConeAngle(20.0f);
Spotlight->GetSpotLightComponent()->SetOuterConeAngle(40.0f);
```

---

## Render Target(텍스처로 렌더링)

### Render Target 생성

```cpp
// Render Target 애셋 생성(2D 텍스처)
UTextureRenderTarget2D* RenderTarget = NewObject<UTextureRenderTarget2D>();
RenderTarget->InitAutoFormat(512, 512); // 512x512 해상도
RenderTarget->UpdateResourceImmediate();

// 씬을 텍스처로 렌더링
UKismetRenderingLibrary::DrawMaterialToRenderTarget(
    GetWorld(),
    RenderTarget,
    MaterialToDraw
);
```

---

## 커스텀 렌더 패스(고급)

### Render Dependency Graph(RDG)

```cpp
// UE5는 커스텀 렌더링에 Render Dependency Graph를 사용함
// 예시: 커스텀 포스트 프로세스 패스

#include "RenderGraphBuilder.h"

void RenderCustomPass(FRDGBuilder& GraphBuilder, const FViewInfo& View) {
    FRDGTextureRef SceneColor = /* 씬 컬러 텍스처 획득 */;

    // 패스 파라미터 정의
    struct FPassParameters {
        FRDGTextureRef InputTexture;
    };

    FPassParameters* PassParams = GraphBuilder.AllocParameters<FPassParameters>();
    PassParams->InputTexture = SceneColor;

    // 렌더 패스 추가
    GraphBuilder.AddPass(
        RDG_EVENT_NAME("CustomPass"),
        PassParams,
        ERDGPassFlags::Raster,
        [](FRHICommandList& RHICmdList, const FPassParameters* Params) {
            // 렌더 명령
        }
    );
}
```

---

## 성능

### 렌더 통계

```cpp
// 프로파일링용 콘솔 명령어:
// stat fps - FPS 표시
// stat unit - 프레임 시간 분해 표시
// stat gpu - GPU 타이밍 표시
// profilegpu - 상세 GPU 프로파일
```

### 확장성(Scalability) 설정

```cpp
// 현재 확장성 설정 가져오기
UGameUserSettings* Settings = UGameUserSettings::GetGameUserSettings();
int32 ViewDistanceQuality = Settings->GetViewDistanceQuality(); // 0-4

// 확장성 설정
Settings->SetViewDistanceQuality(3); // High
Settings->SetShadowQuality(2); // Medium
Settings->ApplySettings(false);
```

---

## 디버깅

### 렌더 기능 시각화

```
콘솔 명령어:
- r.Lumen.Visualize 1 - Lumen 디버그 표시
- r.Nanite.Visualize 1 - Nanite 삼각형 표시
- viewmode wireframe - 와이어프레임 모드
- viewmode unlit - 라이팅 비활성화
- show collision - 충돌 메시 표시
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/lumen-global-illumination-and-reflections-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/nanite-virtualized-geometry-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/substrate-materials-in-unreal-engine/
