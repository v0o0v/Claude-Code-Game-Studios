# Web — UI 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** 모바일에서 `100vh`는 잘못된 값이다(`100dvh`를 쓸 것). 캔버스 콘텐츠는 보조 기술에 전혀 노출되지 않는다

---

## 핵심 결정: DOM인가 캔버스인가

웹 게임에는 다른 어떤 엔진에도 없는 UI 선택지가 있다 — DOM이다. 그리고 거의 항상
DOM이 옳은 선택이다.

| DOM을 쓸 곳 | 캔버스를 쓸 곳 |
|-----------------|----------------|
| 메뉴, 설정, 다이얼로그, 폼 | 월드 오브젝트에 고정되는 HUD |
| 텍스트 입력이 있는 모든 것 | 데미지 숫자, 떠다니는 라벨 |
| 스크린 리더가 필요한 모든 것 | 셰이더 효과가 필요한 요소 |
| 네이티브 스크롤과 포커스 | 렌더링된 씬 내부의 요소 |

**기본값은 DOM이다.** 접근성, 텍스트 레이아웃, 입력 처리, 포커스 관리, 국제화를
공짜로 제공한다. 이것들을 캔버스에서 다시 만드는 일은 비용이 크고 결과도 대개 더
나쁘다. 요소가 반드시 렌더링된 씬 안에 있어야 할 때만 캔버스 UI를 선택한다.

### 레이어 구성
```html
<div id="app">
  <canvas id="game"></canvas>
  <div id="ui"></div>   <!-- absolutely positioned over the canvas -->
</div>
```
```css
#ui { position: absolute; inset: 0; pointer-events: none; }
#ui > * { pointer-events: auto; }   /* re-enable on actual controls */
```
컨테이너에 건 `pointer-events: none`이 실제 UI 요소 위를 제외한 모든 곳에서 클릭이
캔버스까지 통과하도록 만들어 준다.

---

## 뷰포트와 레이아웃

```css
#app {
  height: 100dvh;              /* NOT 100vh — mobile chrome makes vh wrong */
  padding: env(safe-area-inset-top) env(safe-area-inset-right)
           env(safe-area-inset-bottom) env(safe-area-inset-left);
}
```

모바일에서 `100vh`는 브라우저 크롬이 숨겨진 상태를 기준으로 뷰포트를 측정한다.
그래서 레이아웃 하단이 주소창 아래로 들어가고, 주소창이 숨겨질 때마다 위치가
어긋난다. `dvh`는 실제로 보이는 높이를 따라간다.

그 밖의 요구사항:
- 터치 타깃은 최소 44×44 px — 시각적 크기가 아니라 히트 영역을 넓힌다
- 입력 요소의 폰트는 16px 이상이어야 한다. 그렇지 않으면 iOS가 포커스 시 자동 확대한다
- `orientationchange`와 `resize`를 함께, 디바운스해서 처리한다

---

## 접근성

캔버스 콘텐츠는 스크린 리더에 **완전히 보이지 않는다.** 캔버스 안에서만 전달되는
정보는 별도로 만들지 않는 한 접근 가능한 대응물이 없다.

- 시맨틱 요소를 우선한다: `<button>`, `<a>`, `<label>`, `<dialog>`. ARIA는 맞는 요소가 없을 때만 쓴다
- 아이콘만 있는 버튼에는 `aria-label`이 필요하다
- 모든 인터랙티브 요소는 키보드로 도달 가능해야 하며 `:focus-visible` 링이 보여야 한다
- 모달에서는 WAI-ARIA에 따라 포커스를 가둔다. 닫을 때는 트리거로 포커스를 되돌린다
- 명암비 최소 4.5:1. 색만으로 상태를 표시하지 않는다
- `prefers-reduced-motion`을 존중한다 — 그냥 끄지 말고 완화된 변형을 제공한다
- 시각적으로만 알려지는 중요한 상태 변화에는 `aria-live` 영역을 쓴다

```html
<div aria-live="polite" class="sr-only" id="announcer"></div>
```

---

## 성능 — UI가 프레임을 잡아먹어선 안 된다

### 컴포지터 속성만 애니메이션한다
```css
/* ✅ GPU-composited */
transition: transform 150ms ease, opacity 150ms ease;

/* ❌ Forces layout every frame */
transition: all 150ms ease;
```
`width`, `height`, `top`, `left`를 애니메이션하면 매 프레임 리플로우가 발생하고,
이는 게임 스터터로 나타난다 — 레이아웃과 게임 루프는 같은 스레드를 공유한다.

### 매 프레임이 아니라 변경 시점에 갱신한다
```ts
// ❌ Per-frame layout invalidation
function render() { healthEl.textContent = String(hp); }

// ✅ Event-driven
events.on('healthChanged', ({ current }) => {
  healthEl.textContent = String(current);
});
```

### 레이아웃 스래싱을 피한다
DOM 읽기를 모아서 한 뒤 쓰기를 한다. 둘을 번갈아 하면 읽을 때마다 동기 레이아웃이
강제된다.

```ts
// ❌ read → write → read → write forces layout twice
// ✅ read all, then write all
const widths = els.map((el) => el.offsetWidth);
els.forEach((el, i) => { el.style.transform = `translateX(${widths[i]}px)`; });
```

---

## 상태

**UI는 게임 상태를 소유하지 않는다.** 읽고 디스패치할 뿐이다.

```ts
// ✅ UI dispatches intent; the game decides
button.addEventListener('click', () => events.emit('pauseRequested', {}));
```

사용자에게 노출되는 모든 텍스트는 로컬라이제이션 시스템을 거친다. `../modules/`와
프로젝트의 로컬라이제이션 설정을 참고한다 — 하드코딩된 문자열은 번역을 막고 리뷰에서
반려된다.

---

## 캔버스 내 UI (PixiJS)

UI가 정말로 씬 안에 속해야 할 때는 이렇게 한다.

- 매 프레임 갱신되는 것(점수, 타이머, 데미지 숫자)에는 `BitmapText`를 쓴다. 캔버스 `Text`는 내용이 바뀔 때마다 다시 래스터화하고 텍스처를 다시 업로드한다
- Pixi v8은 `SplitText`와 태그 기반 인라인 스타일링을 제공한다 — 여러 `Text` 오브젝트를 쌓는 것보다 이쪽을 택한다
- 캔버스 안에서만 전달되는 정보에는 DOM 대응물을 제공한다

---

## 자주 발생하는 오류

| 증상 | 원인 |
|---------|-------|
| 모바일에서 레이아웃이 밀리거나 잘림 | `100dvh` 대신 `100vh` 사용 |
| 클릭이 캔버스까지 닿지 않음 | UI 컨테이너에 `pointer-events: none` 누락 |
| HUD가 갱신될 때 게임이 끊김 | 매 프레임 `textContent` 쓰기, 또는 레이아웃 속성 애니메이션 |
| 스크린 리더가 아무것도 읽지 않음 | 정보가 캔버스 안에만 있음 |
| 콘텐츠가 노치 아래로 들어감 | `env(safe-area-inset-*)` 누락 |
| 입력에 포커스하면 iOS가 확대함 | 입력 폰트가 16px보다 작음 |

---

## 출처

- https://developer.mozilla.org/en-US/docs/Web/CSS/length#viewport-percentage_lengths
- https://www.w3.org/WAI/ARIA/apg/
- https://pixijs.com/
