# Web (PixiJS / Three.js) — 버전 레퍼런스

**최종 검증일:** 2026-08-06

| 항목 | 값 |
|-------|-------|
| **엔진** | Web (브라우저 런타임) |
| **렌더러** | [CHOOSE: PixiJS (2D) / Three.js (3D) / Both] |
| **PixiJS 버전** | 8.19.0 |
| **Three.js 버전** | r185 (`three@0.185.x`) |
| **TypeScript** | 7.0.x |
| **빌드 도구** | Vite 8.0.x (Rolldown 번들러) |
| **Node.js** | 24.x (Active LTS) |
| **브라우저 기준선** | Chrome/Edge 120+, Firefox 121+, Safari 26+ |
| **그래픽 API** | WebGPU + WebGL2 폴백 |
| **프로젝트 고정일** | 2026-08-06 |
| **문서 최종 검증일** | 2026-08-06 |
| **LLM 지식 컷오프** | 2026년 5월 |
| **위험 수준** | **HIGH — 상시** (아래 참고) |

---

## 지식 공백 경고 — 구조적으로 상시 존재한다

단일 바이너리를 고정하고 모델 업데이트 이후 위험 수준이 낮아지는 Godot, Unity,
Unreal과 달리, 웹 스택의 위험 수준은 **상시 HIGH**다.
이것은 일시적 상태가 아니라 구조적 성질이다:

- **Three.js는 대략 매월 릴리스된다**(2026년 한 해 안에서만 r183 → r184 → r185).
  그리고 **거의 모든 릴리스에서 deprecated 코드를 제거하는** 관행이 문서화되어 있다.
  어떤 모델이든 학습 컷오프는 항상 현재 시점보다 여러 릴리스 뒤에 놓인다.
- **PixiJS v8은 계속 반복 릴리스된다**(2026년 상반기에만 8.16 → 8.19).
- **TypeScript 7.0은 2026년 8월에 완전히 새로운 네이티브 컴파일러를 내놓았다.**
- **Vite 8은 번들러를 통째로 교체했다**(esbuild/Rollup → Rolldown).

**기억에만 의존해 웹 API를 제안하지 말 것.** 항상 `deprecated-apis.md`와
`breaking-changes.md`를 먼저 확인하고, 여기에 없는 내용은 WebSearch로 확인한다.

---

## 라이브러리별 위험 평가

위험은 스택 전체에 한 번이 아니라 라이브러리별로 평가한다.

| 라이브러리 | 모델이 알 법한 범위 | 현재 | 위험 | 주요 위험 요소 |
|---------|--------------------|---------|------|----------------|
| **PixiJS** | v8.0–v8.10 | 8.19.0 | MEDIUM | v7 패턴이 학습 데이터에 깊이 박혀 있고, v8에서는 하드 브레이크다 |
| **Three.js** | ~r170–r178 | r185 | **HIGH** | 매월 deprecated 제거; r183의 `PostProcessing` → `RenderPipeline` 개명 |
| **TypeScript** | 5.x | 7.0.x | MEDIUM | 새 네이티브 컴파일러; `tsc` 플래그와 성능 특성이 바뀜 |
| **Vite** | 5.x–6.x | 8.0.x | MEDIUM | Rolldown 번들러 교체로 플러그인·설정 동작이 바뀜 |
| **Node.js** | 20–22 | 24 LTS | LOW | 추가 위주; 게임 코드에 영향을 주는 파괴적 변경은 거의 없음 |

---

## 컷오프 이후 타임라인 — 무엇이 바뀌었나

| 릴리스 | 시점 | 위험 | 핵심 테마 |
|---------|------|------|-----------|
| Three.js r171 | 2025년 9월 | HIGH | **WebGPURenderer 프로덕션 준비 완료 선언** |
| Three.js r175 | 2025년 | MEDIUM | deprecated 코드 제거 작업 |
| Three.js r183 | 2026년 | **HIGH** | `PostProcessing`이 `RenderPipeline`으로 개명(노드 기반) |
| Three.js r184 | 2026년 4월 | MEDIUM | 점진적 개선; TSL 확장 지속 |
| Three.js r185 | 2026년 | **HIGH** | ClusteredLighting (Forward+), `ExternalTexture`, WebGPU 상의 WebXR, 추가 deprecated 제거 |
| PixiJS 8.16 | 2026년 2월 | LOW | 실험적 Canvas 렌더러; 태그 텍스트 |
| PixiJS 8.17 | 2026년 3월 | LOW | `BlurFilter` 최적화; `visibleChanged` 이벤트 |
| PixiJS 8.18 | 2026년 4월 | LOW | `graphicsContextToSvg()` |
| PixiJS 8.19 | 2026년 6월 | LOW | 점진적 개선 |
| TypeScript 7.0 | 2026년 8월 | MEDIUM | 네이티브 Go 컴파일러, 빌드 8–12배 고속화 |
| Vite 8.0 | 2026년 4월 | MEDIUM | Rolldown을 단일 통합 번들러로 |

---

## 가장 중요한 사실 하나

**이제 WebGPU는 모든 사용자에게 배포할 수 있다.** Three.js `WebGPURenderer`는
r171에서 프로덕션 준비를 마쳤고, PixiJS v8은 설계부터 WebGPU 우선이며, Safari 26이
WebGPU를 지원하면서 마지막 큰 공백이 메워졌다. "WebGPU는 실험적이니 WebGL을 쓰라"는
학습 데이터 시절의 조언은 **낡았다**. 현재 지침은 WebGPU + 자동 WebGL2 폴백이며,
두 라이브러리 모두 기본값으로 그렇게 동작한다.

---

## 검증된 출처

- PixiJS 릴리스: https://github.com/pixijs/pixijs/releases
- PixiJS v8 마이그레이션 가이드: https://pixijs.com/8.x/guides/migrations/v8
- Three.js 릴리스: https://github.com/mrdoob/three.js/releases
- Three.js 마이그레이션 가이드: https://github.com/mrdoob/three.js/wiki/Migration
- Three.js 체인지로그: https://threejs.org/changelog/
- Vite 8 발표: https://vite.dev/blog/announcing-vite8
- Node.js 릴리스 일정: https://nodejs.org/en/blog/announcements/evolving-the-nodejs-release-schedule
