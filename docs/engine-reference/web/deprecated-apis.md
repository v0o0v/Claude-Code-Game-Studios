# Web 스택 — Deprecated API

**최종 검증일:** 2026-08-06

빠른 조회용 문서다. 형식: **X를 쓰지 말 것** → **대신 Y를 쓸 것**.

**PixiJS나 Three.js API를 제안하기 전에** 이 파일을 먼저 확인한다. Three.js는 대부분의
릴리스에서 deprecated 코드를 제거하므로, 여기서 "deprecated"는 흔히 "이미 사라졌다"를 뜻한다.

---

## PixiJS — v7 → v8

| Deprecated / 제거됨 | 대체 | 비고 |
|----------------------|-------------|-------|
| `new PIXI.Application({...})` (동기) | `const app = new Application(); await app.init({...})` | v8에서 init은 비동기다 |
| `app.view` | `app.canvas` | HTML5 명명과 정렬 |
| `PIXI.*` 전역 네임스페이스 | `pixi.js`에서 named ESM import | 전역 번들 래퍼 없음 |
| `@pixi/sprite`, `@pixi/core` 등 하위 패키지 | 단일 `pixi.js` 패키지 | v8은 단일 패키지로 회귀 |
| `BaseTexture` | `Assets.load()`를 통한 `TextureSource` 계열 | `BaseTexture`는 더 이상 없음 |
| `new Texture('url.png')` | `await Assets.load('url.png')` | 텍스처는 로드된 리소스를 요구한다 |
| 로드되지 않은 에셋에 대한 `Texture.from(url)` | `Assets.load(url)` | `Texture.from`은 더 이상 로딩을 유발하지 않는다 |
| `sprite.addChild(...)` | `container.addChild(...)` | `Container`만 자식을 가질 수 있다 |
| `Sprite` 자식을 쓰는 `ParticleContainer` | 파티클 레코드를 쓰는 `ParticleContainer` | v8에서 완전히 재구성됨 |
| `Loader` / `PIXI.Loader` | `Assets` | Assets 매니저가 v7 로더를 대체한다 |
| `app.renderer.plugins.interaction` | `app.stage.eventMode` + federated events | v7/v8에서 이벤트 시스템이 교체됨 |

---

## Three.js — r185 기준 제거 또는 deprecated

| Deprecated / 제거됨 | 대체 | 버전 | 비고 |
|----------------------|-------------|---------|-------|
| `PostProcessing` (`three/webgpu`) | `RenderPipeline` | r183 | **단순 개명.** 가장 빈번한 낡은 제안 |
| `Matrix3.scale()` | 행렬을 명시적으로 합성 | r185 | Deprecated, 제거 예정 |
| `Matrix3.rotate()` | 행렬을 명시적으로 합성 | r185 | Deprecated, 제거 예정 |
| `Matrix3.translate()` | 행렬을 명시적으로 합성 | r185 | Deprecated, 제거 예정 |
| `DRACOLoader.setDecoderConfig()` | 현재 문서화된 디코더 설정 방식 | r185 | Deprecated |
| `LWOLoader` | 원본 에셋을 glTF로 변환 | r185 | Deprecated |
| `WebGPURenderer`에서 원시 GLSL `ShaderMaterial` | TSL / `NodeMaterial` | r171+ | GLSL 문자열은 WebGPU 경로가 아니다 |
| `WebGPURenderer`를 실험적으로 취급 | 프로덕션 준비가 끝났다 | r171 | 학습 시절의 조언은 낡았다 |

### 상시 경고

Three.js는 **r175**와 **r185**에서 deprecated 제거 작업을 수행했고, 이를 일상적으로
반복한다. 어떤 API가 이 레퍼런스 세트에 문서화되어 있지 않고 학습 데이터에서 배운
것이라면, **제안하기 전에 WebSearch로 검증할 것**. r17x에서 경고만 남기던 API가
r185에는 존재하지 않을 수 있다.

---

## 툴체인

| Deprecated | 대체 | 비고 |
|------------|-------------|-------|
| `tsc` 레거시 JS 컴파일러 전제 | TypeScript 7.0 네이티브(Go) 컴파일러 | 8–12배 빠름; 플래그를 재검증할 것 |
| Vite의 esbuild + Rollup 이중 번들러 모델 | Rolldown (단일 통합 번들러) | Vite 8.0 |
| Node 20 / 22를 타깃으로 삼기 | Node 24 Active LTS | Node 26은 2026년 10월 LTS 진입 |

---

## 브라우저 API — 낡아버린 조언

| 낡은 조언 | 현재 현실 |
|--------------|-----------------|
| "WebGPU는 실험적이다 — WebGL로 출시하라" | WebGPU는 모든 사용자에게 배포 가능하다; Safari 26이 공백을 메웠다 |
| "로드 시점에 `AudioContext`를 자유롭게 쓰라" | autoplay 정책상 오디오 시작 전에 사용자 제스처가 필요하다 — 변한 것 없고, 여전히 자주 놓친다 |
| "캔버스 크기 계산에 `window.innerWidth`를 쓰라" | 모바일에서는 `devicePixelRatio`와 `visualViewport`를 함께 고려해야 한다 |
| "전체 높이 캔버스에는 `100vh`" | `100dvh`를 쓸 것 — 모바일 브라우저 크롬이 `vh`를 망가뜨린다 |

---

## 출처

- https://pixijs.com/8.x/guides/migrations/v8
- https://github.com/mrdoob/three.js/wiki/Migration
- https://github.com/mrdoob/three.js/releases/tag/r185
- https://threejs.org/changelog/
