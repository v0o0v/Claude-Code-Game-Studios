# Unreal Engine 5.7 — 주요(Breaking) 변경 사항

**최종 확인일:** 2026-02-13

이 문서는 Unreal Engine 5.3(모델 학습 데이터에 포함되었을 가능성이 높은 버전)과
Unreal Engine 5.7(현재 버전) 사이의 API 파괴적 변경 사항과 동작 차이를 추적한다. 위험도별로 정리되어 있다.

## HIGH RISK — 기존 코드가 깨질 수 있음

### Substrate 머티리얼 시스템(5.7에서 프로덕션 준비 완료)
**버전:** UE 5.5 이상(실험적), 5.7(프로덕션 준비 완료)

Substrate는 레거시 머티리얼 시스템을 모듈형의 물리적으로 정확한 프레임워크로 대체한다.

```cpp
// ❌ OLD: Legacy material nodes (still work but deprecated)
// Standard material graph with Base Color, Metallic, Roughness, etc.

// ✅ NEW: Substrate material layers
// Use Substrate nodes: Substrate Slab, Substrate Blend, etc.
// Modular material authoring with true physical accuracy
```

**마이그레이션:** `Project Settings > Engine > Substrate`에서 Substrate를 활성화하고 Substrate 노드를 사용해 머티리얼을 다시 제작한다.

---

### PCG(절차적 콘텐츠 생성) API 전면 개편
**버전:** UE 5.7(프로덕션 준비 완료)

PCG 프레임워크가 대규모 API 변경과 함께 프로덕션 준비 완료 상태에 도달했다.

```cpp
// ❌ OLD: Experimental PCG API (pre-5.7)
// Old node types, unstable API

// ✅ NEW: Production PCG API (5.7+)
// Use FPCGContext, IPCGElement, new node types
// Stable API, production-ready workflow
```

**마이그레이션:** 5.7 문서의 PCG 마이그레이션 가이드를 따른다. 실험적 PCG 코드는 대규모 리팩터링이 필요할 것으로 예상된다.

---

### Megalights 렌더링 시스템
**버전:** UE 5.5 이상

새로운 조명 시스템은 수백만 개의 다이내믹 광원을 지원한다.

```cpp
// ❌ OLD: Limited dynamic lights (clustered forward shading)
// Max ~100-200 dynamic lights before performance degrades

// ✅ NEW: Megalights (5.5+)
// Millions of dynamic lights with minimal performance cost
// Enable: Project Settings > Engine > Rendering > Megalights
```

**마이그레이션:** 코드 변경은 필요하지 않지만 조명 동작이 달라질 수 있다. 활성화 후 씬을 테스트할 것.

---

## MEDIUM RISK — 동작 변경

### Enhanced Input 시스템(이제 기본값)
**버전:** UE 5.1 이상(권장), 5.7(기본값)

Enhanced Input이 이제 기본 입력 시스템이다.

```cpp
// ❌ OLD: Legacy input bindings (deprecated)
InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

// ✅ NEW: Enhanced Input
SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
}
```

**마이그레이션:** 레거시 입력 바인딩을 Enhanced Input 액션으로 교체한다.

---

### Nanite 기본 활성화
**버전:** UE 5.0 이상(선택), 5.7(권장)

Nanite 가상화 지오메트리가 이제 스태틱 메시에 권장되는 워크플로다.

```cpp
// Enable Nanite on static mesh:
// Static Mesh Editor > Details > Nanite Settings > Enable Nanite Support
```

**마이그레이션:** 고폴리곤 메시를 Nanite로 변환한다. 타겟 플랫폼에서 성능을 테스트할 것.

---

## LOW RISK — 지원 중단(여전히 동작함)

### 레거시 머티리얼 시스템
**상태:** 지원 중단되었지만 여전히 지원됨
**대체:** Substrate 머티리얼 시스템

레거시 머티리얼은 여전히 동작하지만, 신규 프로젝트에는 Substrate가 권장된다.

---

### 구 World Partition(UE4 방식)
**상태:** 지원 중단
**대체:** World Partition(UE5 이상)

대규모 월드에는 UE5의 World Partition 시스템을 사용할 것.

---

## 플랫폼별 주요(Breaking) 변경 사항

### Windows
- **UE 5.7**: DirectX 12가 이제 기본값이다(이전 버전에서는 DX11이었음)
- DX12 호환을 위해 셰이더를 업데이트할 것

### macOS
- **UE 5.5 이상**: Metal 3 필요(최소 macOS 13)

### 모바일
- **UE 5.7**: 최소 Android API 레벨이 26(Android 8.0)으로 상향됨
- 최소 iOS 배포 타겟이 iOS 14로 상향됨

---

## 마이그레이션 체크리스트

UE 5.3에서 UE 5.7로 업그레이드할 때:

- [ ] Substrate 머티리얼 검토(신규 시스템으로 전환할 준비가 되었으면 변환)
- [ ] PCG 사용 현황 감사(실험적 버전을 사용 중이라면 프로덕션 API로 업데이트)
- [ ] Megalights 성능 테스트(활성화 후 벤치마크 진행)
- [ ] 레거시 입력을 Enhanced Input으로 마이그레이션
- [ ] 고폴리곤 메시를 Nanite로 변환
- [ ] DX12(Windows) 또는 Metal 3(macOS)용 셰이더 업데이트
- [ ] 최소 플랫폼 버전 확인(Android 8.0, iOS 14)
- [ ] 타겟 하드웨어에서 Lumen 및 Nanite 성능 테스트

---

**출처:**
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-projects-to-newer-versions-of-unreal-engine
