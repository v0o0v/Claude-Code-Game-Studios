# Web 스택 — 선택 패키지 및 생태계

**최종 검증일:** 2026-08-06

이 문서는 브라우저 게임에서 흔히 쓰이는 **선택적 npm 패키지**를 정리한 색인이다.
PixiJS나 Three.js 코어에 포함된 것이 아니다.

---

## 이 가이드 사용법

**🟡 간단 개요** — 공식 문서 링크; 최신 API 세부는 WebSearch로 확인한다
**⚠️ 검토 필요** — 쓸 만하지만 도입 전에 유지보수 상태를 확인한다
**📦 npm** — npm/pnpm으로 설치한다

> **번들 크기 규율**: 여기 있는 모든 패키지는 페이로드를 늘리고, 페이로드는 웹의
> 결정적 제약이다. 의존성을 추가하기 전에 `web-platform-specialist`에게 gzip 기준
> 비용과 tree-shaking 가능 여부를 평가받는다.
> 함수 하나를 위해 80 KB를 더하는 패키지는 값어치가 없다.

---

## 물리

### 🟡 Rapier
- **용도:** Rust/WASM 물리 엔진, 2D 및 3D
- **사용 시점:** 실제 강체 물리가 필요한 모든 프로젝트
- **선택 이유:** 활발히 유지보수되고, 결정적이며(리플레이와 넷코드에서 중요), JS 네이티브 엔진보다 훨씬 빠르다
- **비용:** WASM 바이너리가 페이로드를 유의미하게 늘린다 — 부트 번들이 아니라 비동기로 로드한다
- **패키지:** `@dimforge/rapier2d` / `@dimforge/rapier3d`
- **공식:** https://rapier.rs/

### ⚠️ Cannon-es
- **용도:** 순수 JS 3D 물리, 원본 cannon.js의 유지보수 포크
- **사용 시점:** WASM 페이로드를 정당화하기 어려운 가벼운 물리 요구
- **트레이드오프:** Rapier보다 느리고 정확도가 낮다
- **패키지:** `cannon-es`

### 🟡 Matter.js
- **용도:** 순수 JS 2D 물리
- **사용 시점:** 성능보다 접근성이 중요한 2D 게임
- **패키지:** `matter-js`

---

## 오디오

### 🟡 Howler.js
- **용도:** 스프라이트 지원과 포맷 폴백을 갖춘 Web Audio 추상화 계층
- **사용 시점:** 대부분의 프로젝트 — 직접 구현하면 번거로운 autoplay 해제 절차, 오디오 스프라이트, 코덱 폴백을 처리해 준다
- **지식 공백:** 특별히 없음; 라이브러리가 안정적이다
- **패키지:** `howler`
- **공식:** https://howlerjs.com/

> 순수 Web Audio도 충분히 쓸 만하며 번들 크기를 전혀 늘리지 않는다. 오디오 요구가
> 단순하다면 그쪽을 택한다. `modules/audio.md` 참고.

---

## 네트워킹 / 멀티플레이

### 🟡 Colyseus
- **용도:** 룸 기반 상태 동기화를 제공하는 서버 권위형 멀티플레이 프레임워크
- **사용 시점:** 서버를 직접 통제하는 실시간 멀티플레이
- **참고:** Node 서버 호스팅이 필요하다 — 정적 호스팅을 넘어서는 상당한 인프라 부담이다
- **패키지:** `colyseus.js` (클라이언트)
- **공식:** https://colyseus.io/

### 🟡 Geckos.io
- **용도:** WebRTC 데이터 채널 위의 UDP 유사 비신뢰 메시징
- **사용 시점:** WebSocket 지연과 head-of-line 블로킹이 문제가 되는 빠른 액션 멀티플레이
- **패키지:** `@geckos.io/client`

WebSocket과 WebRTC 중 무엇을 고를지는 `modules/networking.md`를 참고한다.

---

## PixiJS 생태계

### 🟡 pixi-filters
- **용도:** 즉시 쓸 수 있는 디스플레이 필터 모음(glow, outline, CRT, shockwave 등)
- **사용 시점:** 커스텀 필터를 작성하기 전에 — 여기부터 확인한다
- **중요:** v8 백엔드 동등성을 위해 각 필터가 WGSL과 GLSL 소스를 **모두** 제공하는지 확인한다
- **패키지:** `pixi-filters`

### 🟡 @pixi/sound
- **용도:** Pixi `Assets` 로더와 통합된 오디오
- **사용 시점:** 오디오와 텍스처에 하나의 에셋 파이프라인을 쓰고 싶은 Pixi 프로젝트
- **패키지:** `@pixi/sound`

---

## Three.js 생태계

### 🟡 three/addons (번들된 예제)
- **용도:** 로더(GLTF, DRACO, KTX2), 컨트롤(Orbit, Pointer Lock), 헬퍼
- **사용 시점:** 상시 — `GLTFLoader`, `DRACOLoader`, `KTX2Loader`가 전부 여기 있다
- **참고:** `three`와 함께 배포되지만 메인 엔트리 포인트에는 **없다**. `three/addons/...`에서 import하고 tree-shaking을 확인한다
- **공식:** https://threejs.org/docs/

### 🟡 postprocessing (pmndrs)
- **용도:** WebGL 경로용 병합 패스 포스트 프로세싱 라이브러리
- **사용 시점:** 단순 체이닝보다 적은 전체 화면 패스로 효과를 넣고 싶은 WebGL 프로젝트
- **⚠️ 중요:** **WebGPU** 경로에서는 이 라이브러리 대신 Three 내장 **`RenderPipeline`**(r183에서 `PostProcessing`에서 개명)을 쓴다
- **패키지:** `postprocessing`

### 🟡 three-mesh-bvh
- **용도:** 가속된 레이캐스팅과 공간 질의
- **사용 시점:** 복잡한 지오메트리에 대한 잦은 레이캐스트(피킹, 발사체, 캐릭터 컨트롤러)
- **패키지:** `three-mesh-bvh`

---

## 툴링

### 🟡 gltf-transform / gltfpack
- **용도:** CLI 기반 GLTF 최적화 — DRACO 압축, 텍스처 변환, 메시 단순화
- **사용 시점:** 항상, 모든 3D 프로젝트의 빌드 단계로
- **이유:** 웹 3D 게임이 쓸 수 있는 페이로드 절감 수단 중 레버리지가 가장 크다

### 🟡 TexturePacker / 무료 아틀라스 패커
- **용도:** 스프라이트 아틀라스 생성
- **사용 시점:** 모든 2D 프로젝트 — 개별 PNG는 드로우 콜과 요청 수를 배로 늘린다

### 🟡 vite-plugin-pwa
- **용도:** 서비스 워커와 오프라인 지원
- **사용 시점:** 오프라인 플레이나 설치 가능성이 실제 요구사항일 때만 — 캐시 무효화 복잡도가 늘어난다

---

## 검증

### 🟡 Zod
- **용도:** 타입 추론을 갖춘 런타임 스키마 검증
- **사용 시점:** 모든 외부 경계에서 — 레벨 JSON, 세이브 데이터, `localStorage`, 네트워크 메시지
- **이유:** TypeScript 타입은 런타임에 사라진다. 경계를 넘어오는 것은 파싱하기 전까지 전부 `unknown`이다
- **패키지:** `zod`

---

## 출처

- https://rapier.rs/
- https://howlerjs.com/
- https://colyseus.io/
- https://threejs.org/docs/
- https://pixijs.com/
