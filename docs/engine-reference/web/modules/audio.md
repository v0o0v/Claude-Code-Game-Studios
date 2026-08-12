# Web — 오디오 모듈 레퍼런스

**최종 검증일:** 2026-08-06
**지식 격차:** 큰 격차는 없다 — 다만 자동 재생을 위한 사용자 제스처 요구사항은 이 플랫폼에서 가장 자주 놓치는 제약이다

---

## 모든 프로젝트를 무너뜨리는 단 하나의 규칙

**사용자 제스처 없이는 오디오를 시작할 수 없다.** 브라우저는 사용자가 페이지와
상호작용하기 전까지 `AudioContext`를 정지 상태로 둔다. 우회 방법도, 플래그도,
권한 요청 프롬프트도 없다.

모든 웹 게임에는 명시적인 시작 상호작용이 필요하다.

```ts
const ctx = new AudioContext();   // starts in state 'suspended'

// 실제 사용자 제스처 핸들러 안에서 실행해야 한다
startButton.addEventListener('click', async () => {
  await ctx.resume();             // now 'running'
  startGame();
});
```

설계상의 함의: "클릭해서 시작" 화면은 취향의 문제가 아니라 플랫폼 요구사항이다.
나중에 덧붙이지 말고 타이틀 화면에 자연스럽게 녹여 넣는다.

또한 탭 포커스가 돌아온 뒤에는 `ctx.state`를 다시 확인한다 — 일부 브라우저는 다시
정지 상태로 돌린다.

---

## Web Audio 그래프

```
AudioBufferSourceNode → GainNode (per-category) → GainNode (master) → destination
```

믹싱이 가능하도록 모든 사운드를 카테고리 버스를 거쳐 라우팅한다.

```ts
const master = ctx.createGain();
master.connect(ctx.destination);

const sfxBus = ctx.createGain();
const musicBus = ctx.createGain();
sfxBus.connect(master);
musicBus.connect(master);
```

### 볼륨 변경은 반드시 램프 처리한다
```ts
// ❌ Audible click
gain.gain.value = 0.5;

// ✅ Smooth
gain.gain.setTargetAtTime(0.5, ctx.currentTime, 0.01);
```
`.value`를 직접 설정하면 파형에 불연속이 생기고, 이는 클릭이나 팝 소리로 들린다.

### 소스는 일회용이다
`AudioBufferSourceNode`는 재생을 반복할 수 없다. 재생할 때마다 새로 만든다 — 이는
의도된 설계이고 비용도 저렴하다. 재사용해야 할 것은 노드가 아니라 디코딩된
`AudioBuffer`다.

```ts
function play(buffer: AudioBuffer, bus: GainNode): void {
  const src = ctx.createBufferSource();
  src.buffer = buffer;              // buffer is reused
  src.connect(bus);
  src.start();                      // node is disposable
}
```

---

## 포맷

| 포맷 | 용도 |
|--------|-----|
| **Opus in WebM** | 기본 — 바이트당 품질이 가장 좋다 |
| **AAC in MP4** | 구형 Safari용 폴백 |
| WAV | 절대 배포하지 않는다 — 무압축이라 용량이 거대하다 |

2D 게임에서 오디오는 종종 가장 큰 에셋 카테고리다. 공격적으로 압축한다. 음악은
96–128 kbps 스테레오, SFX는 64–96 kbps 모노면 게임플레이 맥락에서 대체로 열화가
느껴지지 않는다.

### 오디오 스프라이트
짧은 SFX들을 하나의 파일로 이어 붙이고 오프셋으로 재생한다. 요청 횟수와 디코딩
오버헤드를 크게 줄여 준다.

```ts
src.start(0, sprite.offset, sprite.duration);
```

---

## 타이밍

**절대 `setTimeout`으로 오디오를 스케줄링하지 않는다.** 해상도가 수십 밀리초 단위이고,
백그라운드 탭에서는 스로틀링된다.

```ts
// ✅ Sample-accurate scheduling on the audio clock
src.start(ctx.currentTime + 0.5);
```

`ctx.currentTime`이 오디오 클록이다. 리듬 게임과 비트 동기 음악에서는
`requestAnimationFrame`이 아니라 이 클록을 기준으로 스케줄링을 구동한다.

한 음씩 스케줄링하지 말고 룩어헤드 윈도(보통 100ms) 안에서 미리 스케줄링한다 —
오디오 스레드가 메인 스레드를 기다리는 일은 없어야 한다.

---

## 모바일 제약

- iOS는 동시에 존재할 수 있는 `AudioContext` 인스턴스 수를 제한한다 — 게임 전체에서 정확히 하나만 쓴다
- 백그라운드 탭은 오디오를 정지시킨다. `visibilitychange`를 처리해 음악을 명시적으로 일시정지한다
- iOS의 무음/벨소리 스위치가 일부 구성에서 Web Audio에 영향을 준다 — 중요한 피드백을 오디오에만 의존하지 않는다
- 저사양 폰에서는 디코딩 비용이 크다. 로딩 중에 디코딩하고, 게임플레이 도중에는 하지 않는다

---

## Howler.js — 언제 쓸 것인가

`howler`는 자동 재생 잠금 해제, 오디오 스프라이트, 포맷 폴백, 풀링 등 손으로 짜기
번거로운 부분을 처리해 준다. 대부분의 프로젝트에서 약 20KB의 값어치를 한다.

다음의 경우에는 순수 Web Audio를 선호한다: 오디오 요구가 단순하거나, 래퍼가 추상화해
가려버리는 샘플 단위 정밀 스케줄링이 프로젝트에 필요한 경우.

`../PLUGINS.md`를 참고한다.

---

## 흔한 오류

| 증상 | 원인 |
|---------|-------|
| 오류도 없이 소리가 전혀 나지 않는다 | 제스처 이후 `AudioContext`를 resume하지 않음 |
| 볼륨을 바꿀 때 클릭/팝 소리가 난다 | 램프 대신 `gain.value`를 직접 설정 |
| "Cannot call start more than once" | `AudioBufferSourceNode`를 재사용함 |
| 음악의 싱크가 어긋난다 | `ctx.currentTime` 대신 `setTimeout`으로 스케줄링 |
| 탭 전환 후 오디오가 멈춘다 | `visibilitychange`를 처리하지 않음 |
| 다운로드 용량이 거대하다 | WAV나 무압축 음악을 배포함 |

---

## 출처

- https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API
- https://developer.chrome.com/blog/autoplay/
- https://howlerjs.com/
