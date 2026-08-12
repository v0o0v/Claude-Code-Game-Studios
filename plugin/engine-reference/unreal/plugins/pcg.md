# Unreal Engine 5.7 — PCG(Procedural Content Generation)

**최종 확인일:** 2026-02-13
**상태:** 프로덕션 레디(UE 5.7 기준)
**플러그인:** `PCG` (기본 내장, Plugins에서 활성화)

---

## 개요

**Procedural Content Generation(PCG)**은 대규모로 프로시저럴 콘텐츠를 생성하기 위한
Unreal의 노드 기반 프레임워크다. 대형 오픈 월드에 식생, 바위, 소품, 건물 및 기타
환경 디테일을 채워 넣기 위해 설계되었다.

**PCG를 사용해야 하는 경우:**
- 프로시저럴 식생 배치(나무, 잔디, 바위)
- 바이옴 기반 환경 생성
- 도로/경로 생성
- 건물/구조물 배치
- 월드 디테일 채우기(소품, 잡동사니)

**PCG를 사용하지 말아야 하는 경우:**
- 게임플레이 로직(Blueprint/C++를 사용할 것)
- 일회성 수동 배치(에디터 도구를 사용할 것)

**⚠️ 참고:** PCG는 UE 5.0~5.6에서 실험적 단계였으며, UE 5.7에서 프로덕션 레디가 되었다.

---

## 핵심 개념

### 1. **PCG Graph**
- 노드 기반 그래프(Material Editor와 유사)
- 생성 규칙을 정의

### 2. **PCG Component**
- 레벨에 배치되어 PCG Graph를 실행
- 정의된 볼륨 내에서 콘텐츠를 생성

### 3. **PCG Data**
- 포인트 데이터(위치, 회전, 스케일)
- 스플라인 데이터(경로, 도로, 강)
- 볼륨 데이터(밀도, 바이옴 마스크)

### 4. **Nodes**
- **Samplers**: 포인트를 생성(Grid, Poisson, Surface)
- **Filters**: 규칙에 따라 포인트를 제거(Density, Tag, Bounds)
- **Modifiers**: 포인트를 변형(Offset, Rotate, Scale)
- **Spawners**: 포인트 위치에 메시/액터를 인스턴스화

---

## 설정

### 1. 플러그인 활성화

`Edit > Plugins > PCG > Enabled > Restart`

### 2. PCG Volume 생성

1. Place Actors > Volumes > PCG Volume
2. 원하는 생성 영역에 맞게 볼륨 크기를 조정

### 3. PCG Graph 생성

1. Content Browser > PCG > PCG Graph
2. PCG Graph 에디터를 연다

---

## 기본 워크플로

### 예시: 숲 생성

#### 1. PCG Graph 생성

**노드 구성:**
```
Input (Volume)
  ↓
Surface Sampler (sample volume surface, points per m²: 0.5)
  ↓
Density Filter (use texture mask or noise)
  ↓
Static Mesh Spawner (tree meshes)
  ↓
Output
```

#### 2. Volume에 그래프 할당

1. PCG Volume을 선택
2. Details Panel > PCG Component > Graph = 작성한 PCG Graph
3. "Generate" 버튼 클릭

---

## 주요 노드 유형

### Samplers(포인트 생성)

#### Grid Sampler
- 규칙적인 격자 형태의 포인트
- 구성 항목:
  - **Grid Size**: 포인트 간 거리
  - **Offset**: 포인트별 랜덤 오프셋

#### Poisson Disk Sampler
- 최소 거리를 유지하는 랜덤 포인트
- 구성 항목:
  - **Points Per m²**: 밀도
  - **Min Distance**: 포인트 간 간격

#### Surface Sampler
- 메시 표면 또는 랜드스케이프 위의 포인트
- 구성 항목:
  - **Points Per m²**: 밀도
  - **Surface Only**: 볼륨이 아닌 표면에만 적용

---

### Filters(포인트 제거)

#### Density Filter
- 밀도 값에 따라 포인트를 제거
- 입력: 텍스처 또는 노이즈
- 용도: 바이옴 마스크, 공터, 경로

#### Tag Filter
- 태그를 기준으로 포인트를 필터링
- 용도: 조건부 스폰

#### Bounds Filter
- 경계 내부의 포인트만 유지
- 용도: 특정 영역으로 생성 범위 제한

---

### Modifiers(포인트 변형)

#### Rotate
- 포인트 회전을 무작위화
- 구성 항목:
  - **Min/Max Rotation**: 축별 회전 범위

#### Scale
- 포인트 스케일을 무작위화
- 구성 항목:
  - **Min/Max Scale**: 스케일 범위

#### Project to Ground
- 포인트를 랜드스케이프 표면에 스냅

---

### Spawners(메시/액터 인스턴스화)

#### Static Mesh Spawner
- 포인트 위치에 스태틱 메시를 스폰
- 구성 항목:
  - **Mesh List**: 메시 배열(무작위 선택)
  - **Culling Distance**: LOD/컬링 설정

#### Actor Spawner
- 포인트 위치에 Blueprint 액터를 스폰
- 용도: 게임플레이 액터, 상호작용 오브젝트

---

## 데이터 소스

### Landscape
- 랜드스케이프를 샘플링 입력으로 사용
- 랜드스케이프 높이에 자동으로 투영

### Splines
- 스플라인을 따라 콘텐츠를 생성(도로, 강, 경로)
- 예시: 경로를 따라 배치되는 나무

### Textures
- 텍스처를 밀도 마스크로 사용
- 바이옴, 공터, 영역을 페인팅

---

## 바이옴 예시(혼합림)

### 그래프 구성

```
Input (Landscape)
  ↓
Surface Sampler (density: 1.0)
  ↓
┌─────────────────┬─────────────────┐
│ Tree Biome      │ Rock Biome      │
│ (density > 0.5) │ (density < 0.5) │
├─────────────────┼─────────────────┤
│ Tree Spawner    │ Rock Spawner    │
└─────────────────┴─────────────────┘
  ↓
Merge
  ↓
Output
```

---

## 스플라인 기반 생성(가로수가 있는 도로)

### 1. PCG Graph 생성

```
Spline Input
  ↓
Spline Sampler (sample along spline)
  ↓
Offset (offset from spline path)
  ↓
Tree Spawner
  ↓
Output
```

### 2. PCG Volume에 Spline Component 추가

1. PCG Volume > Add Component > Spline
2. 스플라인 경로를 그린다
3. PCG Graph가 스플라인 데이터를 읽는다

---

## 런타임 생성

### C++에서 생성 트리거

```cpp
#include "PCGComponent.h"

UPCGComponent* PCGComp = /* Get PCG Component */;
PCGComp->Generate(); // Execute PCG graph
```

### 스트리밍 생성(대형 월드)

- PCG는 World Partition과 함께 자동으로 스트리밍된다
- 로드된 셀 내부에서만 콘텐츠를 생성한다

---

## 성능

### 최적화 팁

- 스폰된 메시에 **culling distance**(LOD)를 사용한다
- **밀도**를 제한한다(포인트 수가 적을수록 성능이 좋다)
- 반복되는 메시에는 **Hierarchical Instanced Static Meshes(HISM)**를 사용한다
- 대형 월드에서는 **streaming**을 활성화한다

### 성능 디버깅

```cpp
// Console commands:
// pcg.graph.debug 1 - Show PCG debug info
// stat pcg - Show PCG performance stats
```

---

## 일반적인 패턴

### 공터가 있는 숲

```
Surface Sampler
  ↓
Density Filter (noise texture with clearings)
  ↓
Tree Spawner (pine, oak, birch)
```

---

### 급경사면의 바위

```
Landscape Input
  ↓
Surface Sampler
  ↓
Slope Filter (angle > 30°)
  ↓
Rock Spawner
```

---

### 도로변 소품

```
Spline Input (road spline)
  ↓
Spline Sampler
  ↓
Offset (side of road)
  ↓
Street Light Spawner
```

---

## 디버깅

### PCG 디버그 시각화

```cpp
// Console commands:
// pcg.debug.display 1 - Show points and generation bounds
// pcg.debug.colormode points - Color-code points
```

### 그래프 디버깅

- PCG Graph Editor > Debug > Show Debug Points
- 그래프의 각 노드에서 포인트를 시각화

---

## UE 5.6(실험적)에서 5.7(프로덕션)로 마이그레이션

### API 변경 사항

```cpp
// ❌ OLD (5.6 experimental API):
// Some nodes renamed, API unstable

// ✅ NEW (5.7 production API):
// Stable node types, documented API
```

**마이그레이션:** 안정화된 5.7 노드를 사용해 PCG 그래프를 재구성할 것. 충분히 테스트할 것.

---

## 제약 사항

- **게임플레이 로직에는 사용 불가**: 게임 규칙에는 Blueprint/C++를 사용할 것
- **큰 그래프는 느려질 수 있음**: 필터와 밀도 축소로 최적화할 것
- **런타임 생성 오버헤드**: 가능하면 사전 생성(pre-generate)할 것

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/pcg-quick-start-in-unreal-engine/
- UE 5.7 릴리스 노트(PCG 프로덕션 레디 발표)
