# Web 스택 — 파괴적 변경 사항

**최종 검증일:** 2026-08-06

모델이 학습했을 법한 내용과 현재 고정된 스택 사이의 파괴적 API 변경과 동작 차이를
정리한다. 라이브러리별로, 그 안에서는 위험 수준별로 정렬했다.

---

# PixiJS

## HIGH RISK — v8에서 하드 브레이크인 v7 패턴

모델의 학습 데이터에는 PixiJS v7 코드가 대량으로 들어 있다. 아래 패턴들은 v8에서
**동작하지 않는다**.

### Application 초기화가 이제 비동기다

WebGPU와 WebGL2를 판별하려면 비동기 핸드셰이크가 필요하므로, 렌더러를 더 이상
생성자에서 만들 수 없다.

```ts
// ❌ OLD (v7): synchronous constructor
const app = new PIXI.Application({ width: 800, height: 600 });
document.body.appendChild(app.view);

// ✅ NEW (v8): async init, and `view` is now `canvas`
import { Application } from 'pixi.js';

const app = new Application();
await app.init({ width: 800, height: 600 });
document.body.appendChild(app.canvas);
```

**마이그레이션:** 모든 진입점이 async가 된다. `app.view` → `app.canvas`.

---

### `BaseTexture`는 더 이상 존재하지 않는다

```ts
// ❌ OLD (v7)
const base = new PIXI.BaseTexture('sprite.png');
const texture = new PIXI.Texture(base);

// ✅ NEW (v8): load through Assets; Texture expects a loaded resource
import { Assets, Sprite } from 'pixi.js';

const texture = await Assets.load('sprite.png');
const sprite = new Sprite(texture);
```

**이유:** v8에서 텍스처는 더 이상 무언가를 로드하는 방법을 알지 못한다. 로딩은
`Assets` 매니저의 역할이고, `Texture`는 이미 해석이 끝난 `TextureSource`를
감싼다. URL 문자열로 `Texture`를 생성하면 v7에서는 조용히 로드되지 않은 텍스처가
만들어졌는데, v8에서는 아예 지원하지 않는다.

---

### 전역 `PIXI` 네임스페이스가 사라졌다

```ts
// ❌ OLD (v7)
const sprite = new PIXI.Sprite(texture);

// ✅ NEW (v8): named ESM imports from the single package
import { Sprite } from 'pixi.js';
const sprite = new Sprite(texture);
```

v8은 **단일 패키지**로도 되돌아갔다 — `@pixi/*` 하위 패키지를 설치하지 말 것.

---

### `Container`만 자식을 가질 수 있다

```ts
// ❌ OLD (v7): Sprite could parent other display objects
sprite.addChild(childSprite);

// ✅ NEW (v8): use an explicit Container
const group = new Container();
group.addChild(sprite, childSprite);
```

---

### `ParticleContainer` 재구성

`ParticleContainer`는 더 이상 `Sprite` 자식을 받지 않는다. 대신 파티클 레코드를
받으며, 이것이 v8에서 훨씬 많은 파티클 수를 감당할 수 있게 해 주는 요인이다.
v7 파티클 코드는 조정이 아니라 다시 작성해야 한다.

---

## MEDIUM RISK — 동작 변경

### WebGPU가 기본 렌더러다
v8은 자동으로 감지해 WebGPU를 우선하고, WebGL2로 폴백한다. WebGL만 가정하고 작성된
셰이더 코드는 WGSL 대응본이 필요할 수 있다. 명확한 이유가 있을 때만
`await app.init({ preference: 'webgl' })`로 백엔드를 강제한다.

---

# Three.js

## HIGH RISK — 이름이 바뀌거나 제거된 것

### `PostProcessing` → `RenderPipeline` (r183)

```ts
// ❌ OLD (pre-r183)
import { PostProcessing } from 'three/webgpu';
const post = new PostProcessing(renderer);

// ✅ NEW (r183+)
import { RenderPipeline } from 'three/webgpu';
const pipeline = new RenderPipeline(renderer);
```

**이유:** 이 클래스는 단순한 포스트 패스가 아니라 렌더 파이프라인 전체를 구동한다는
점을 반영해 이름이 바뀌었다. 옛 이름이 학습 데이터를 지배하고 있어서, 에이전트가
제안할 가능성이 가장 높은 낡은 API다.

---

### 거의 매 릴리스마다 deprecated 코드가 제거된다

r175와 r185는 각각 deprecated 제거 작업을 수행했으며, 이는 예외가 아니라 통상적인
관행이다. 모델이 학습한 버전에서는 경고만 뜨던 API가 r185에서는 **아예 없을** 수 있다.

**규칙:** 이 레퍼런스 세트에서 확인하지 않은 Three.js API를 제안하기 전에
`deprecated-apis.md`를 확인하고, 이어서 WebSearch로 현재 문서를 확인한다.

---

### `Matrix3.scale()` / `.rotate()` / `.translate()` deprecated (r185)

제거 예정으로 표시되었다. 이 헬퍼로 변형을 변이시키지 말고 트랜스폼을 명시적으로
합성한다.

---

### 로더 변경 (r185)

| 변경 | 조치 |
|--------|--------|
| `DRACOLoader.setDecoderConfig()` deprecated | 현재 문서화된 경로로 디코더를 설정한다 |
| `LWOLoader` deprecated | 에셋을 glTF로 변환한다 |

---

## MEDIUM RISK — 이제 WebGPU가 권장 경로다

`WebGPURenderer`는 **r171**(2025년 9월)부터 프로덕션 준비를 마쳤고, Safari 26이
WebGPU를 탑재하며 마지막 브라우저 공백이 메워졌다. WebGPU를 실험적인 것으로 다루라던
학습 시절의 조언은 낡았다.

```ts
// 현재 권장 설정
import { WebGPURenderer } from 'three/webgpu';
const renderer = new WebGPURenderer({ antialias: true });
await renderer.init(); // async, like PixiJS v8
```

`WebGLRenderer`는 계속 지원된다. 다만 이제 그것을 고르는 것은 기본값이 아니라
의도적인 호환성 결정이다.

**r185의 WebGPU 신규 사항:** `ClusteredLighting`(Forward+ 클러스터드 셰이딩),
render-to-texture-array, 완전한 `ExternalTexture` 지원, WebGPU 상의 WebXR.

---

### TSL (Three Shading Language)이 노드 머티리얼 경로다

TSL은 매 릴리스마다 계속 확장된다. r185는 `textureGather`,
`textureGatherCompare`, `storageTexture3D`, `ambientOcclusion` 프로퍼티를 추가했고
벡터 `not()`을 성분 단위로 동작하게 바꿨다. `WebGPURenderer`용 머티리얼을 작성하는
지원 경로는 원시 GLSL 문자열이 아니라 TSL이다.

---

# 툴체인

## TypeScript 7.0 (2026년 8월) — MEDIUM RISK

TypeScript 7.0은 컴파일러를 **네이티브 Go 구현**으로 교체해 빌드를 8–12배 빠르게
만들었다. 타입 검사 의미론은 호환을 목표로 하지만, 빌드 툴링·플래그·에디터 연동이
바뀌었다. `tsconfig.json` 옵션은 기억이 아니라 현재 문서를 기준으로 확인한다.

## Vite 8.0 (2026년 4월) — MEDIUM RISK

Vite 8은 esbuild + Rollup 이원 구조를 대체해 **Rolldown**(Rust)을 단일 통합
번들러로 탑재했고, 빌드가 10–30배 빨라졌다. 플러그인 호환성은 대체로 유지되지만,
커스텀 Rollup 플러그인 동작과 번들러 종속 설정은 다시 검증해야 한다.

## Node.js 24 LTS

Node 24가 Active LTS 라인이며, Node 26은 2026년 10월에 LTS로 진입한다. 여기서
Node는 런타임이 아니라 툴링과 CI에만 쓰이므로 게임 코드에 대한 위험은 낮다.

---

## 출처

- https://pixijs.com/8.x/guides/migrations/v8
- https://github.com/pixijs/pixijs/releases
- https://github.com/mrdoob/three.js/releases
- https://github.com/mrdoob/three.js/wiki/Migration
- https://vite.dev/blog/announcing-vite8
