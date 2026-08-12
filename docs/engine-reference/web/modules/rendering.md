# Web — 렌더링 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** WebGPU는 두 라이브러리 모두에서 프로덕션 사용이 가능하다. Three의 후처리 클래스는 r183에서 이름이 변경되었다

---

## 개요

| 레이어 | PixiJS v8 | Three.js r185 |
|-------|-----------|---------------|
| 백엔드 | WebGPU → WebGL2 폴백 (자동) | `WebGPURenderer` → `WebGLRenderer` |
| 초기화 | `await app.init()` | `await renderer.init()` |
| 셰이딩 | 필터 (WGSL + GLSL) | TSL / `NodeMaterial` |
| 후처리 | 컨테이너에 `Filter` 적용 | `RenderPipeline` |

**둘 다 비동기로 초기화된다.** 진입점은 반드시 `async`여야 한다.

---

## PixiJS 렌더링

### 설정
```ts
import { Application } from 'pixi.js';

const app = new Application();
await app.init({
  width: 800,
  height: 600,
  antialias: true,
  autoDensity: true,
  resolution: window.devicePixelRatio,
});
document.body.appendChild(app.canvas);   // NOT app.view
```

### 드로우 콜 배칭
드로우 콜은 2D의 주된 병목이다. Pixi는 공격적으로 배칭하지만, 다음 상황에서는 배치가 끊긴다.

| 배치를 깨뜨리는 요인 | 해결책 |
|---------------|-----|
| 형제 노드 사이의 텍스처 변경 | 하나의 아틀라스로 묶는다 |
| 목록 중간 자식 노드에 걸린 필터 | 컨테이너 레벨에서 적용하거나 순서를 바꾼다 |
| 형제 노드 사이의 `blendMode` 변경 | 블렌드 모드별로 그룹화한다 |
| `Graphics`와 `Sprite`가 번갈아 배치됨 | 레이어를 분리한다 |

변경 전후로 렌더러의 드로우 콜 수를 측정한다. 추측하지 않는다.

### 컬링
```ts
container.cullable = true;
container.cullArea = new Rectangle(0, 0, worldWidth, worldHeight);
```
큰 스크롤 월드에서는 직접 만든 가시성 검사보다 이 방식을 우선한다.

---

## Three.js 렌더링

### 설정
```ts
import { WebGPURenderer } from 'three/webgpu';

const renderer = new WebGPURenderer({ antialias: true });
await renderer.init();
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); // cap DPR
renderer.setSize(window.innerWidth, window.innerHeight);
```

`devicePixelRatio`를 2로 제한하는 것이 표준이다. 그 이상에서는 특히 모바일에서
필레이트 비용이 시각적 이득을 정당화하는 경우가 드물다.

### 후처리 — `RenderPipeline`
```ts
// ❌ Pre-r183 — the name that dominates training data
import { PostProcessing } from 'three/webgpu';

// ✅ r183+
import { RenderPipeline } from 'three/webgpu';
const pipeline = new RenderPipeline(renderer);
```

### 인스턴싱
```ts
const mesh = new InstancedMesh(geometry, material, count);
// 행렬을 제자리에서 갱신한 뒤:
mesh.instanceMatrix.needsUpdate = true;
```
- `InstancedMesh` — 하나의 geometry+material을 여러 벌 복제 → 드로우 콜 1회
- `BatchedMesh` — 하나의 material을 공유하는 *서로 다른* geometry 여럿

프레임마다 메시를 다시 생성하지 않는다.

### 라이팅 (r185)
`ClusteredLighting`(Forward+ 클러스터드 셰이딩)이 r185에서 `WebGPURenderer`에
도입되어, 감당 가능한 라이트 수가 상당히 늘어났다. "라이트는 4개 미만으로 유지하라"는
과거의 경험칙이 여전히 유효하다고 가정하기 전에 최신 문서를 확인한다.

그림자는 여전히 비싸다 — 가능한 한 적은 수의 라이트에서만 그림자를 드리우고,
`shadow.camera` 경계를 플레이 영역에 꼭 맞게 조인다.

---

## 해제 — 양쪽 모두 해당

어느 라이브러리도 GPU 메모리를 자동으로 해제하지 않는다. 씬 그래프에서 객체를
제거하는 것만으로는 해제되지 **않는다**.

```ts
// Three.js
geometry.dispose();
material.dispose();
texture.dispose();

// PixiJS — texture: false when the atlas is shared
container.destroy({ children: true, texture: false });
```

해제 누락의 증상: 레벨 전환마다 메모리가 계속 올라가다가 결국 탭이 죽는다.
메모리를 관찰하면서 씬을 반복 전환해 테스트한다.

---

## 해상도와 DPR

```ts
// Cap DPR — full DPR on a 4K display is 8M+ fragments per full-screen pass
const dpr = Math.min(window.devicePixelRatio, 2);
```

후처리를 낮은 해상도로 렌더링한 뒤 업샘플링하는 것은 bloom, blur, AO에서 표준적인
방식이다. 이런 효과들은 그 차이를 눈에 띄지 않게 흡수한다.

---

## 흔한 오류

| 증상 | 원인 |
|---------|-------|
| `app.view is undefined` | v7 패턴 — `app.canvas`를 사용한다 |
| `PostProcessing is not exported` | r183에서 `RenderPipeline`으로 이름이 바뀌었다 |
| 생성 직후 렌더러 메서드가 실패한다 | `await init()` 누락 |
| 씬을 넘길 때마다 메모리가 증가한다 | `dispose()` / `destroy()` 누락 |
| 4K에서 프레임레이트가 급락한다 | `devicePixelRatio`를 제한하지 않음 |
| 2D에서 드로우 콜이 많다 | 텍스처를 묶지 않아 배치가 깨짐 |

---

## 출처

- https://pixijs.com/8.x/guides/migrations/v8
- https://github.com/mrdoob/three.js/releases/tag/r185
- https://threejs.org/docs/
