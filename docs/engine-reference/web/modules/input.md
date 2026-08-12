# Web — 입력 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** Pointer Events가 마우스/터치 개별 처리를 대체한다. 게임패드에는 이벤트 API가 없다

---

## 개요

| 입력 | API | 모델 |
|-------|-----|-------|
| 마우스 / 터치 / 펜 | **Pointer Events** | 이벤트 기반 |
| 키보드 | `keydown` / `keyup` | 이벤트 기반 |
| 게임패드 | `navigator.getGamepads()` | **폴링** |
| 터치 제스처 | Pointer Events + 수동 추적 | 이벤트 기반 |

---

## Pointer Events — 모든 입력을 하나의 경로로

`mousedown`과 `touchstart` 핸들러를 따로 작성하지 않는다. Pointer Events는 마우스,
터치, 펜을 단일 코드 경로로 처리한다.

```ts
canvas.addEventListener('pointerdown', (e: PointerEvent) => {
  canvas.setPointerCapture(e.pointerId);   // keep receiving events outside the canvas
  input.press(e.pointerId, e.offsetX, e.offsetY);
});

canvas.addEventListener('pointermove', (e: PointerEvent) => {
  input.move(e.pointerId, e.offsetX, e.offsetY);
});

canvas.addEventListener('pointerup', (e: PointerEvent) => {
  canvas.releasePointerCapture(e.pointerId);
  input.release(e.pointerId);
});
```

동작을 다르게 처리해야 할 때는 `e.pointerType`이 `'mouse' | 'touch' | 'pen'`을 준다.
포인터가 캔버스를 벗어나도 드래그가 이어지게 만드는 것이 `setPointerCapture`다.

### 필수 CSS
```css
canvas {
  touch-action: manipulation;  /* kills the 300ms double-tap zoom delay */
  user-select: none;
}
```

---

## 키보드

### 상태를 버퍼링하고, 고정 업데이트에서 읽는다
이벤트는 임의의 시점에 도착한다. 시뮬레이션은 고정 타임스텝으로 돈다. 상태 객체에
버퍼링해 두고 `update()` 안에서 읽는다.

```ts
const keys = new Set<string>();
addEventListener('keydown', (e) => { keys.add(e.code); });
addEventListener('keyup',   (e) => { keys.delete(e.code); });
```

이동에는 `e.code`(레이아웃과 무관한 물리 키)를 쓴다 — `e.key`는 AZERTY와 Dvorak에서
잘못된 결과를 준다. 텍스트 입력에는 `e.key`를 쓴다.

### 포커스를 잃으면 눌림 상태를 초기화한다
```ts
addEventListener('blur', () => keys.clear());
document.addEventListener('visibilitychange', () => {
  if (document.hidden) keys.clear();
});
```
이 처리가 없으면, 플레이어가 이동 중에 alt-tab으로 나갔다 돌아왔을 때 캐릭터가 벽에
계속 부딪히고 있게 된다. 웹 게임에서 가장 흔한 버그 중 하나다.

### `preventDefault`의 범위를 좁힌다
게임이 실제로 사용하는 키에 대해서만, 그리고 캔버스가 포커스를 가진 경우에만 기본
동작을 막는다. document 전체에 무차별적으로 `preventDefault`를 걸면 브라우저 단축키,
스크롤, 접근성 도구가 망가진다.

---

## 게임패드 — 이벤트가 아니라 폴링

버튼 상태를 위한 게임패드 이벤트 API는 없다. 게임 루프 안에서 폴링한다.

```ts
function pollGamepads(): void {
  const pads = navigator.getGamepads();
  for (const pad of pads) {
    if (!pad) continue;
    const x = applyDeadzone(pad.axes[0] ?? 0);
    const jump = pad.buttons[0]?.pressed ?? false;
    // ...
  }
}

function applyDeadzone(v: number, dz = 0.15): number {
  return Math.abs(v) < dz ? 0 : (v - Math.sign(v) * dz) / (1 - dz);
}
```

- `getGamepads()`는 **스냅샷**을 반환한다 — 매 프레임 호출하고, 배열을 캐시하지 않는다
- 게임패드는 사용자가 버튼을 누른 뒤에야 나타난다(프라이버시 조치). `gamepadconnected`를 수신해 감지한다
- 항상 데드존을 적용한다. 원시 스틱 값은 드리프트한다
- 데드존 이후 위 코드처럼 재스케일해 0–1 전 구간에 도달할 수 있게 한다

---

## 입력 추상화

원시 디바이스를 게임 액션으로 매핑하는 지점을 한 곳으로 모은다. 리바인딩, 리플레이,
게임패드 지원은 모두 게임이 디바이스를 직접 읽지 않는다는 전제에 기댄다.

```ts
type Action = 'moveLeft' | 'moveRight' | 'jump' | 'interact';

interface InputState {
  isDown(action: Action): boolean;
  justPressed(action: Action): boolean;   // edge-detected in the fixed update
  axis(action: Action): number;
}
```

에지 감지(`justPressed`)는 이벤트 핸들러가 아니라 고정 업데이트에서 계산해야 한다.
그렇지 않으면 프레임 타이밍에 따라 입력이 누락되거나 중복 집계될 수 있다.

---

## 모바일 특이사항

- 최소 터치 타깃은 44×44 px. 시각적 크기가 아니라 히트 영역을 넓힌다
- 노치와 홈 인디케이터에는 `env(safe-area-inset-*)`를 사용한다
- 입력 요소는 폰트가 16px 이상이어야 한다. 그렇지 않으면 iOS가 포커스 시 자동 확대한다
- 화면상 컨트롤은 위치를 옮길 수 있어야 한다 — 엄지가 닿는 범위는 사람마다 다르다
- `orientationchange`와 `resize`를 함께, 디바운스해서 처리한다

---

## 흔한 오류

| 증상 | 원인 |
|---------|-------|
| alt-tab 후 이동 키가 눌린 채로 남는다 | `blur`에서 상태를 초기화하지 않음 |
| 캔버스를 벗어나면 드래그가 끊긴다 | `setPointerCapture` 누락 |
| 모바일에서 탭이 300ms 지연된다 | `touch-action: manipulation` 누락 |
| 게임패드가 전혀 감지되지 않는다 | 폴링하지 않았거나, 사용자가 아직 버튼을 누르지 않음 |
| 가만히 있어도 스틱이 드리프트한다 | 데드존 없음 |
| AZERTY에서 WASD가 어긋난다 | `e.code` 대신 `e.key` 사용 |

---

## 출처

- https://developer.mozilla.org/en-US/docs/Web/API/Pointer_events
- https://developer.mozilla.org/en-US/docs/Web/API/Gamepad_API
