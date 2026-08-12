# Web — 물리 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** PixiJS도 Three.js도 물리 엔진을 내장하지 않는다 — 물리는 항상 의존성 선택의 문제다

---

## 개요

**두 라이브러리 모두 물리를 포함하지 않는다.** Godot, Unity, Unreal과 달리 내장
강체(rigid-body) 시스템도, 캐릭터 컨트롤러도, 충돌 레이어도 없다. 물리는 실제
페이로드 비용을 수반하는 의도적인 의존성 선택이다.

| 필요 | 권장 |
|------|----------------|
| 아케이드식 충돌 (AABB, 원) | **직접 구현한다** — 수백 줄이면 충분하고 페이로드는 0 |
| 진짜 2D 강체 | Rapier 2D |
| 진짜 3D 강체 | Rapier 3D |
| 가벼운 3D, 페이로드에 민감한 경우 | Cannon-es |
| 접근성 좋은 2D | Matter.js |

플랫포머, 탑다운, 퍼즐, 슈팅 등 대부분의 2D 게임은 **물리 엔진이 전혀 필요하지 않다**.
AABB 겹침 판정에 스윕 충돌만 더하면 충분하고, 더 빠르며, 완전히 결정론적이고,
번들 크기도 늘리지 않는다. 스태킹, 조인트, 연속 동역학이 정말로 필요할 때만
엔진을 도입한다.

---

## Rapier (Rust/WASM)

진짜 물리가 필요할 때의 기본 권장안이다.

- 플랫폼 간 **결정론적** — 리플레이, 넷코드, 재현 가능한 테스트에 결정적으로 중요하다
- JS 네이티브 엔진보다 상당히 빠르다
- WASM 바이너리는 무시할 수 없는 페이로드 비용이다 — **비동기로 로드하고**, 부트 번들에는 절대 넣지 않는다

```ts
import RAPIER from '@dimforge/rapier2d';

await RAPIER.init();                       // async WASM load
const world = new RAPIER.World({ x: 0, y: -9.81 });

const body = world.createRigidBody(
  RAPIER.RigidBodyDesc.dynamic().setTranslation(0, 10)
);
world.createCollider(RAPIER.ColliderDesc.cuboid(0.5, 0.5), body);
```

### 고정 업데이트에서 스텝을 진행한다
```ts
function update(dt: number): void {
  world.timestep = dt;      // match the fixed timestep exactly
  world.step();
  syncTransformsToRenderer();
}
```

물리는 렌더 주기가 아니라 고정 주기로 스텝해야 한다. `render()`에서 스텝하면
시뮬레이션이 프레임레이트에 종속되고 결정론성이 무너진다.

---

## 물리 → 렌더러 동기화

위치는 물리가 소유하고, 렌더러는 그것을 표시한다. 둘이 서로에게 쓰게 두지 않는다.

```ts
// One direction only: physics → renderer
const t = body.translation();
sprite.position.set(t.x * PIXELS_PER_METER, -t.y * PIXELS_PER_METER);
```

**단위 스케일이 중요하다.** 물리 엔진은 미터 단위에 맞춰 튜닝되어 있다. 픽셀 스케일
값(가로 32단위 상자)을 넣으면 솔버는 가로 32미터짜리 상자를 시뮬레이션하듯 동작한다
— 모든 것이 슬로모션으로 움직이고 떨린다. `PIXELS_PER_METER` 상수를 정하고(32나 100이
흔하다) 경계에서 변환한다.

Y축 반전에 유의한다. 화면 Y는 아래로 증가하고, 물리 Y는 위로 증가한다.

### 보간
고정 타임스텝을 쓸 때는 물리 상태 사이를 보간해 렌더링해야 한다. 그러지 않으면
스텝 주기로 정확히 나누어떨어지지 않는 주사율에서 움직임이 끊겨 보인다.

```ts
const x = prev.x + (curr.x - prev.x) * alpha;   // alpha = accumulator / STEP
```

---

## 직접 구현하기 (2D 아케이드)

대부분의 2D 게임에서는 이것이 정답이다.

```ts
function aabbOverlap(a: Rect, b: Rect): boolean {
  return a.x < b.x + b.w && a.x + a.w > b.x &&
         a.y < b.y + b.h && a.y + a.h > b.y;
}
```

- **빠른 물체는 스윕한다.** 프레임당 40px로 움직이는 발사체는 도착 지점만 검사하면 16px 벽을 그대로 통과해버린다. 이동 경로 전체를 검사한다
- 플랫포머의 손맛을 위해 **축을 분리해 해석한다**(X 다음 Y) — 벽 슬라이딩과 난간 동작이 예측 가능해진다
- 엔티티 수가 약 100을 넘으면 **브로드 페이즈를 내로우 페이즈보다 먼저** 둔다: 공간 해시나 균일 그리드로 후보를 추린 뒤 후보에만 정밀 검사를 수행한다

---

## 성능

- 물리는 CPU 바운드이며 메인 스레드에서 게임 루프와 경쟁한다
- 정지한 바디는 슬립시킨다 — 대부분의 엔진이 자동으로 처리하지만, 활성화되어 있는지 확인한다
- 솔버 반복 횟수를 제한한다. 많이 돌린다고 눈에 띄게 좋아지는 경우는 드물다
- Web Worker에 물리를 올릴 수도 있지만, 경계를 넘나드는 트랜스폼 동기화 비용이 이득을 상쇄하는 경우가 많다. 도입을 결정하기 전에 측정한다

---

## 흔한 오류

| 증상 | 원인 |
|---------|-------|
| 모든 것이 슬로모션으로 움직인다 | 미터 스케일 솔버에 픽셀 단위를 넣음 |
| 빠른 물체가 벽을 통과한다 | 스윕 충돌 / CCD 없음 |
| 물리 속도가 프레임레이트에 따라 변한다 | 고정 `update()`가 아니라 `render()`에서 스텝함 |
| 144Hz에서 움직임이 떨린다 | 물리 상태 사이 보간 없음 |
| 물체가 바닥에 가라앉는다 | 매 프레임 동기화가 바디 쪽으로 되쓰기됨 |
| 초기 로딩이 길다 | WASM 물리가 부트 번들에 포함됨 |

---

## 출처

- https://rapier.rs/docs/
- https://github.com/pmndrs/cannon-es
- https://brm.io/matter-js/
