# Web — Animation 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** 큰 격차는 없다 — 반복해서 발생하는 위험은 고정 타임스텝 대신 렌더 델타로 애니메이션을 구동하는 것이다

---

## 개요

| 애니메이션 종류 | PixiJS | Three.js |
|----------------|--------|----------|
| 스프라이트 / 프레임 | `AnimatedSprite` | — |
| 스켈레탈 | Spine / DragonBones 런타임 | `AnimationMixer` (GLTF clips) |
| 트윈 | 직접 구현하거나 트윈 라이브러리 | 직접 구현하거나 트윈 라이브러리 |
| 모프 타깃 | — | 모프 타깃 influence |
| 프로시저럴 | 커스텀, update 루프 안에서 | 커스텀, update 루프 안에서 |

두 라이브러리 모두 트윈 시스템을 기본 제공하지 않는다. 작은 의존성을 하나 추가하거나
직접 100줄 정도를 작성하는 선택의 문제다.

---

## 타임스텝 규칙

애니메이션 상태는 렌더 패스가 아니라 **고정 업데이트(fixed update)** 에서 진행한다.
렌더 델타로 구동하면 애니메이션 속도가 프레임레이트에 종속되어, 144Hz 모니터가
60Hz와 다른 애니메이션을 재생하게 된다.

```ts
// ✅ In fixed update
function update(dt: number): void {
  mixer.update(dt);           // Three.js
  animState.advance(dt);      // your own sprite animation
}
```

예외는 게임플레이 의미가 전혀 없는 순수 시각적 보간이다. 이런 것은 보간 알파를 써서
렌더 시점에 처리해도 된다.

---

## PixiJS — 스프라이트 애니메이션

```ts
import { AnimatedSprite, Assets } from 'pixi.js';

const sheet = await Assets.load('hero.json');   // atlas + frame data
const run = new AnimatedSprite(sheet.animations.run);
run.animationSpeed = 0.2;
run.play();
```

- 모든 애니메이션 프레임을 **하나의 atlas**에 팩킹한다 — 프레임이 여러 텍스처에 흩어지면 배칭이 깨진다
- 게임플레이에 영향을 주는 타이밍(공격 유효 프레임, 무적 프레임)은 `animationSpeed`가 아니라 직접 만든 상태 머신에서 프레임 인덱스를 구동한다. 그래야 타이밍이 결정론적이고 테스트 가능하다
- `AnimatedSprite`는 공유 ticker를 사용한다. 게임을 일시정지했다면 명시적으로 멈춰야 한다

---

## Three.js — 스켈레탈 애니메이션

```ts
import { AnimationMixer } from 'three';

const gltf = await loader.loadAsync('character.glb');
const mixer = new AnimationMixer(gltf.scene);
const clip = gltf.animations.find((c) => c.name === 'Run');
const action = mixer.clipAction(clip!);
action.play();

// 고정 업데이트에서
mixer.update(dt);
```

### 클립 간 블렌딩
```ts
current.crossFadeTo(next, 0.25, false);
next.play();
```
크로스페이드 길이는 손맛(feel) 파라미터다 — 하드코딩하지 말고 튜닝 노브로 노출한다.

### 비용
- 스킨드 메시는 정적 메시보다 비싸다. 스키닝 비용은 본 개수와 버텍스 개수에 비례해 증가한다
- 클립마다가 아니라 캐릭터마다 `AnimationMixer` 하나를 공유한다
- 씬을 정리할 때 `mixer.stopAllAction()`을 호출하고 dispose한다. 그러지 않으면 애니메이션 상태가 누수된다

---

## 트윈

최소한의 트윈 구현이 의존성 추가보다 나은 경우가 많다.

```ts
interface Tween {
  elapsed: number; duration: number;
  from: number; to: number;
  ease: (t: number) => number;
  apply: (v: number) => void;
}

function stepTween(tw: Tween, dt: number): boolean {
  tw.elapsed += dt;
  const t = Math.min(tw.elapsed / tw.duration, 1);
  tw.apply(tw.from + (tw.to - tw.from) * tw.ease(t));
  return t >= 1;   // done
}
```

자주 쓰는 이징 — UI 등장에는 `easeOutCubic`, 카메라 이동에는 `easeInOutQuad`,
경쾌한 팝 효과에는 `easeOutBack`.

**할당 주의:** 매 프레임 트윈 객체를 생성하면 GC의 원인이 된다. 풀링하거나 고정 크기
트윈 슬롯 배열을 쓴다.

---

## DOM UI에는 CSS 애니메이션

DOM UI에서는 JS 애니메이션보다 CSS를 우선한다.

```css
.panel { transition: transform 200ms ease, opacity 200ms ease; }
@media (prefers-reduced-motion: reduce) {
  .panel { transition-duration: 1ms; }
}
```

- `transform`과 `opacity`만 애니메이션한다 — 나머지는 전부 리플로우를 강제한다
- `transition: all`은 절대 쓰지 않는다
- `prefers-reduced-motion` 변형을 항상 제공한다

---

## 자주 발생하는 오류

| 증상 | 원인 |
|---------|-------|
| 고주사율 모니터에서 애니메이션이 더 빠르게 재생됨 | 고정 타임스텝이 아니라 렌더 델타로 구동 |
| 일시정지 중에도 애니메이션이 계속됨 | 일시정지 시 `AnimatedSprite`/mixer를 멈추지 않음 |
| 스프라이트 애니메이션이 배칭을 깨뜨림 | 프레임이 여러 텍스처에 흩어져 있음 |
| 캐릭터를 스폰할수록 메모리가 증가함 | `AnimationMixer`를 dispose하지 않음 |
| 트윈이 많을 때 GC 스파이크 | 매 프레임 트윈 객체를 할당 |
| 멀미를 호소하는 피드백 | `prefers-reduced-motion` 미처리 |

---

## 출처

- https://threejs.org/docs/#manual/en/introduction/Animation-system
- https://pixijs.com/
- https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion
