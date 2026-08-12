# Web 스택 — 현행 모범 사례

**최종 검증일:** 2026-08-06

LLM 학습 데이터에 없을 수 있는 최신 웹 게임 패턴을 정리한다. 고정된 스택 기준으로
프로덕션에 바로 쓸 수 있는 권장 사항이다.

---

## 프로젝트 셋업

### WebGPU로 출시한다
학습 컷오프 이후 가장 중요한 변화다. `WebGPURenderer`는 Three.js **r171**에서
프로덕션 준비를 마쳤고, PixiJS v8은 설계부터 WebGPU 우선이며,
**Safari 26이 WebGPU를 추가**하면서 마지막 주요 브라우저 공백이 메워졌다.

두 라이브러리 모두 자동 감지 후 WebGL2로 폴백한다. 기본값을 쓰고, 문서화된 이유가
있을 때만 백엔드를 강제하되 폴백 경로가 실제로 동작하는지 검증한다.

### 두 라이브러리 모두 비동기로 초기화된다
```ts
// PixiJS v8
const app = new Application();
await app.init({ width: 800, height: 600 });

// Three.js WebGPURenderer
const renderer = new WebGPURenderer({ antialias: true });
await renderer.init();
```
진입점이 `async`가 된다. 모듈 구조를 그 전제 위에 설계한다.

### Vite 8 + TypeScript 7
Vite 8은 **Rolldown**(Rust)을 단일 통합 번들러로 탑재해, 기존 esbuild+Rollup 조합
대비 빌드가 10–30배 빠르다. TypeScript 7.0의 **네이티브 Go 컴파일러**는 이전 대비
8–12배 빠르다. 설정 플래그는 현재 문서를 기준으로 재검증한다 — 기억하고 있는 옵션의
위치가 바뀌었을 수 있다.

---

## 아키텍처

### 고정 타임스텝은 항상
시뮬레이션을 원시 `requestAnimationFrame` 델타로 구동하지 말 것 — 물리가
프레임레이트에 종속되어, 144Hz 모니터에서는 60Hz와 다른 게임이 된다.

```ts
const STEP = 1 / 60;
let accumulator = 0;

function frame(now: number): void {
  const delta = Math.min((now - last) / 1000, 0.25); // clamp for tab refocus
  last = now;
  accumulator += delta;
  while (accumulator >= STEP) {
    world.update(STEP);
    accumulator -= STEP;
  }
  render(accumulator / STEP);
  requestAnimationFrame(frame);
}
```

clamp가 중요하다: 백그라운드로 내려간 탭은 수 초 단위 델타를 만들어내고, clamp가
없으면 `while` 루프가 수천 번 돌면서 페이지가 멈춘다.

### 시뮬레이션은 GPU 없이 돌게 유지한다
렌더링을 인터페이스 뒤로 격리해 `world.update()`가 캔버스 없이 Vitest에서 헤드리스로
돌게 한다. 소프트웨어 렌더러 없이도 웹 게임을 CI에서 테스트 가능하게 만드는 요인이며,
가장 큰 레버리지를 갖는 아키텍처 결정이다.

### 의존 방향
`core` ← `gameplay` ← `ui`. ESLint `no-restricted-imports`로 강제해, 위반이 코드
리뷰가 아니라 빌드에서 실패하게 만든다.

---

## 성능

### GC가 프레임 타임의 주범이다
웹에서 눈에 띄는 끊김을 만드는 것은 보통 드로우 콜이 아니라 가비지 컬렉션 일시 정지다.
업데이트·렌더 루프에서 **정상 상태 할당 0**을 목표로 한다.

루프 밖으로 빼야 할 할당 패턴:
- 객체·배열 리터럴 (`{ x, y }`, `[a, b]`)
- `.map()`, `.filter()`, `.reduce()`, 스프레드
- 프레임마다 생성되는 클로저
- 문자열 연결과 템플릿 리터럴
- 인라인 비교자를 쓰는 `Array.prototype.sort()`

벡터, 행렬, 파티클, 발사체는 풀링한다. 스크래치 객체는 재사용한다.

### 해제는 명시적으로 — 자동인 것은 없다
```ts
// Three.js
geometry.dispose(); material.dispose(); texture.dispose();

// PixiJS
container.destroy({ children: true, texture: false });
```
씬 그래프에서 객체를 제거해도 GPU 메모리는 **해제되지 않는다**. 해제 누락은 레벨
전환마다 메모리가 계속 올라가다 탭이 죽는 형태로 드러난다. 씬을 반복해서 순환시키며
메모리를 관찰해 검증한다.

### 페이로드가 이 플랫폼의 제약이다
콘솔 게임은 80GB로 출시한다. 로딩에 20초 걸리는 웹 게임은 이미 플레이어를 잃은 것이다
— itch.io에서 플레이어는 클릭 한 번이면 떠난다.

| 지표 | 목표 |
|--------|--------|
| 초기 JS (gzip) | < 300 KB |
| 첫 상호작용까지의 시간 | 4G에서 < 3초 |
| 초기 다운로드 총량 | < 2 MB |

예산을 세우고, CI에서 확인한다. 아무도 측정하지 않는 예산은 예산이 아니다.

### 에셋을 제대로 압축한다
| 에셋 | 포맷 |
|-------|--------|
| 3D 지오메트리 | GLTF + DRACO |
| 3D 텍스처 | KTX2 / Basis |
| 2D 스프라이트 | 패킹된 아틀라스, WebP 또는 AVIF |
| 오디오 | WebM 컨테이너의 Opus, AAC 폴백 |

KTX2/Basis는 두 번 이득이다: 다운로드가 작아지고 **동시에** VRAM도 작아진다. 중급
사양 휴대폰이 죽지 않게 해 주는 것이 바로 이 지점이다.

---

## 브라우저 플랫폼의 현실

학습 데이터 시절과 달라지지 않았지만, 여전히 가장 자주 놓치는 항목들이다:

- **오디오에는 사용자 제스처가 필요하다.** 모든 프로젝트에는 `AudioContext`를 재개하는
  명시적인 "클릭해서 시작" 단계가 필요하다. 우회 방법은 없다
- **`100vh`가 아니라 `100dvh`** — 모바일 브라우저 크롬 때문에 `vh`는 틀린 값이 된다
- **Pointer Events**를 쓰고 마우스/터치 핸들러를 따로 두지 않는다 — 한 경로로 전부 커버된다
- **게임패드는 폴링이 필요하다** — 루프 안에서 `navigator.getGamepads()`를 호출한다. 이벤트 API는 없다
- **`devicePixelRatio`**를 캔버스 크기 계산에 반영해야 하며, 4K 디스플레이에서 전체 DPR로
  렌더링하는 것은 필레이트 비용을 감안하면 대개 남는 장사가 아니다
- **에셋 보호는 불가능하다.** 배포된 모든 것은 다운로드된다. 절대 비밀 값을 번들에 넣지 말 것
- **`blur`/`visibilitychange`에서 눌린 입력을 초기화**하지 않으면, 플레이어는 이동 키가
  눌린 채 고정된 상태로 돌아온다

---

## 테스트

- 단위 테스트는 **Vitest** — 어디서나 돌도록 GPU 없이 유지한다
- E2E는 **Playwright**
- CI에서 헤드리스 WebGL/WebGPU를 쓰려면 소프트웨어 렌더러(SwiftShader)가 필요하다.
  거기에 의존하는 테스트 비중은 최소화한다
- 결정성: 고정 타임스텝이 시뮬레이션을 재현 가능하게 만든다 — 렌더된 픽셀이 아니라
  시뮬레이션 상태를 단언한다

---

## 출처

- https://pixijs.com/8.x/guides/migrations/v8
- https://github.com/mrdoob/three.js/releases
- https://vite.dev/blog/announcing-vite8
- https://threejs.org/changelog/
