# Unity 6.3 — Cinemachine

**최종 확인일:** 2026-02-13
**상태:** 프로덕션 준비 완료
**패키지:** `com.unity.cinemachine` v3.0+ (Package Manager)

---

## 개요

**Cinemachine**은 Unity의 가상 카메라 시스템으로, 수작업 스크립팅 없이도 전문적이고
역동적인 카메라 동작을 구현할 수 있게 해준다. Unity 카메라 작업의 업계 표준이다.

**Cinemachine을 사용해야 하는 경우:**
- 3인칭 추적 카메라
- 컷신 및 시네마틱
- 카메라 블렌딩 및 전환
- 동적인 카메라 프레이밍
- 화면 흔들림 및 카메라 효과

**⚠️ 지식 공백:** Cinemachine 3.0 (Unity 6)은 2.x 버전을 전면 재작성한 것이다.
많은 API 이름과 컴포넌트가 변경되었다.

---

## 설치

### Package Manager를 통한 설치

1. `Window > Package Manager`
2. Unity Registry > "Cinemachine" 검색
3. `Cinemachine` (버전 3.0 이상) 설치

---

## 핵심 개념

### 1. **가상 카메라 (Virtual Cameras)**
- 카메라 동작(위치, 회전, 렌즈)을 정의
- 여러 개의 가상 카메라가 존재할 수 있으나, 한 번에 하나만 "live" 상태

### 2. **Cinemachine Brain**
- 메인 Camera에 붙는 컴포넌트
- 가상 카메라 간 블렌딩을 수행
- 가상 카메라 설정을 Unity Camera에 적용

### 3. **우선순위 (Priorities)**
- 가상 카메라는 우선순위 값을 가짐
- 우선순위가 가장 높은 카메라가 활성 상태가 됨
- 우선순위가 바뀌면 부드럽게 블렌딩됨

---

## 기본 설정

### 1. 메인 카메라에 Cinemachine Brain 추가

```csharp
// 첫 가상 카메라 생성 시 자동으로 추가됨
// 또는 수동으로: Add Component > Cinemachine Brain
```

### 2. 가상 카메라 생성

`GameObject > Cinemachine > Cinemachine Camera`

이렇게 하면 기본 설정을 가진 **CinemachineCamera** 게임오브젝트가 생성된다.

---

## 가상 카메라 컴포넌트

### CinemachineCamera (Unity 6 / Cinemachine 3.0+)

```csharp
using Unity.Cinemachine;

public class CameraController : MonoBehaviour {
    public CinemachineCamera virtualCamera;

    void Start() {
        // 우선순위 설정 (높을수록 활성화됨)
        virtualCamera.Priority = 10;

        // 추적 대상 설정
        virtualCamera.Follow = playerTransform;

        // 주시 대상 설정
        virtualCamera.LookAt = playerTransform;
    }
}
```

---

## 추적 모드 (Body 컴포넌트)

### 3rd Person Follow (Orbital Follow)

```csharp
// Inspector에서:
// CinemachineCamera > Body > 3rd Person Follow

// 설정 항목:
// - Shoulder Offset: 어깨너머 시점을 위해 (0.5, 0, 0)
// - Camera Distance: 5.0
// - Vertical Damping: 0.5 (상하 움직임을 부드럽게)
```

### Framing Transposer (Smooth Follow)

```csharp
// CinemachineCamera > Body > Position Composer

// 설정 항목:
// - Screen Position: 중앙 (0.5, 0.5)
// - Dead Zone: 대상이 이 영역 안에 있으면 카메라를 움직이지 않음
// - Damping: 부드러운 추적
```

### Hard Lock (정확한 추적)

```csharp
// CinemachineCamera > Body > Hard Lock to Target
// 카메라가 오프셋이나 감쇠 없이 대상의 위치와 정확히 일치함
```

---

## 조준 모드 (Aim 컴포넌트)

### Composer (대상 프레이밍)

```csharp
// CinemachineCamera > Aim > Composer

// 설정 항목:
// - Tracked Object Offset: 발이 아니라 대상의 머리를 조준
// - Screen Position: 화면상에서 대상이 표시될 위치
// - Dead Zone: 대상이 이 영역 안에 있으면 회전하지 않음
```

### Look At Target

```csharp
// CinemachineCamera > Aim > Rotate With Follow Target
// 카메라 회전이 대상의 회전과 일치함 (예: 1인칭 시점)
```

---

## 카메라 간 블렌딩

### 우선순위 기반 블렌딩

```csharp
public CinemachineCamera normalCamera; // 우선순위: 10
public CinemachineCamera aimCamera;    // 우선순위: 5

void StartAiming() {
    // 조준 카메라의 우선순위를 더 높게 설정
    aimCamera.Priority = 15; // 이제 활성화됨
    // Brain이 normalCamera에서 aimCamera로 자동으로 블렌딩함
}

void StopAiming() {
    aimCamera.Priority = 5; // 원래대로 복귀
}
```

### 커스텀 블렌드 시간

```csharp
// 커스텀 블렌드 에셋 생성:
// Assets > Create > Cinemachine > Cinemachine Blender Settings

// Cinemachine Brain에서:
// - Custom Blends = 방금 만든 에셋
// - 카메라 쌍별 블렌드 시간 설정
```

---

## 카메라 흔들림 (Camera Shake)

### Impulse Source (흔들림 발생)

```csharp
using Unity.Cinemachine;

public class ExplosionShake : MonoBehaviour {
    public CinemachineImpulseSource impulseSource;

    void Explode() {
        // 카메라 흔들림 발생
        impulseSource.GenerateImpulse();
    }
}
```

### Impulse Listener (흔들림 수신)

```csharp
// CinemachineCamera에 추가:
// Add Component > CinemachineImpulseListener

// Impulse Listener는 주변 Impulse Source의 흔들림을 자동으로 수신함
```

---

## 프리룩 카메라 (마우스 시점의 3인칭)

### Cinemachine Free Look

```csharp
// GameObject > Cinemachine > Cinemachine Free Look

// 수직 입력에 따라 블렌딩되는 3개의 리그(Top, Middle, Bottom)를 생성
// 설정 항목:
// - Orbit Radius: 대상으로부터의 거리
// - Height Offset: 각 리그의 카메라 높이
// - X/Y Axis: 마우스 또는 조이스틱 입력
```

---

## 상태 기반 카메라 (애니메이터 기반)

### Cinemachine State-Driven Camera

```csharp
// GameObject > Cinemachine > Cinemachine State-Driven Camera

// 설정 항목:
// - Animated Target: Animator를 가진 캐릭터
// - Layer: 추적할 Animator 레이어
// - State: 애니메이션 상태별로 카메라 할당 (Idle, Run, Jump 등)

// 애니메이션 상태에 따라 카메라가 자동으로 전환됨
```

---

## 돌리 트랙 (컷신용)

### Cinemachine Dolly Track

```csharp
// 1. 스플라인 생성: GameObject > Cinemachine > Cinemachine Spline

// 2. 돌리 카메라 생성:
//    GameObject > Cinemachine > Cinemachine Camera
//    Body > Spline Dolly
//    스플라인 할당

// 3. 스플라인 위의 돌리 위치를 애니메이션 (Timeline 또는 스크립트로)
```

---

## 공통 패턴

### 3인칭 추적 카메라

```csharp
// CinemachineCamera
// - Follow: 플레이어 Transform
// - Body: 3rd Person Follow (어깨 오프셋, 거리: 5)
// - Aim: Composer (플레이어를 화면 중앙에 프레이밍)
```

---

### 조준 카메라 (줌인)

```csharp
// 일반 카메라 (우선순위 10):
//   - Distance: 5.0

// 조준 카메라 (우선순위 5):
//   - Distance: 2.0
//   - FOV: 더 좁게

// 스크립트:
void StartAiming() {
    aimCamera.Priority = 15; // 조준 카메라로 블렌딩
}
```

---

### 컷신 카메라 시퀀스

```csharp
// Timeline 사용:
// 1. Timeline 생성 (Assets > Create > Timeline)
// 2. Cinemachine Track 추가
// 3. 클립으로 가상 카메라 추가
// 4. Timeline이 카메라 간 블렌딩을 자동으로 처리함
```

---

## Cinemachine 2.x로부터의 마이그레이션 (Unity 2021)

### API 변경 사항 (Unity 6 / Cinemachine 3.0)

```csharp
// ❌ 이전 방식 (Cinemachine 2.x):
CinemachineVirtualCamera vcam;
vcam.m_Follow = target;

// ✅ 새로운 방식 (Cinemachine 3.0+):
CinemachineCamera vcam;
vcam.Follow = target; // 더 깔끔한 API
```

**주요 변경 사항:**
- `CinemachineVirtualCamera` → `CinemachineCamera`
- `m_Follow`, `m_LookAt` → `Follow`, `LookAt` ("m_" 접두사 제거)
- 컴포넌트 이름이 더 명확하게 변경됨
- 성능 향상

---

## 성능 팁

- 활성 가상 카메라 수를 제한할 것 (필요할 때만 활성화)
- 카메라를 파괴/생성하는 대신 우선순위를 낮춰서 처리할 것
- 플레이어와 멀리 떨어진 가상 카메라는 비활성화할 것

---

## 디버깅

### Cinemachine Debug

```csharp
// Window > Analysis > Cinemachine Debugger
// 활성 카메라, 블렌드 정보, 샷 품질을 표시함
```

---

## 출처
- https://docs.unity3d.com/Packages/com.unity.cinemachine@3.0/manual/index.html
- https://learn.unity.com/tutorial/cinemachine
