# Godot 렌더링 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.6 변경 사항
- **Windows에서 D3D12가 기본 렌더링 백엔드다**(이전에는 Vulkan)
- **Glow가 이제 톤매핑 이전에 처리된다**(이전에는 이후였다) — screen 블렌딩 모드를 사용한다
- **AgX 톤매퍼**: 화이트 포인트 및 콘트라스트 컨트롤 신규 추가
- **SSR 전면 개편**: 사실감, 시각적 안정성, 성능이 향상되었다

### 4.5 변경 사항
- **셰이더 베이커**: 셰이더를 사전 컴파일하여 시작 시간을 단축한다
- **SMAA 1x**: 새로운 안티앨리어싱 옵션(FXAA보다 선명하고, TAA보다 저렴하다)
- **스텐실 버퍼 지원**: 선택적 지오메트리 마스킹/포털 이펙트를 가능하게 한다
- **벤트 노멀 맵**: 노멀 맵 텍스처에 방향성 오클루전을 인코딩한다
- **스페큘러 오클루전**: 앰비언트 오클루전이 이제 반사에도 올바르게 반영된다

### 4.4 변경 사항
- **`RenderingDevice.draw_list_begin`**: 다수의 파라미터가 제거되고, 선택적 `breadcrumb`가 추가되었다
- **셰이더 텍스처 타입**: `Texture2D`에서 `Texture` 기반 타입으로 변경되었다
- **Particles `.restart()`**: 선택적 `keep_seed` 파라미터가 추가되었다

### 4.3 변경 사항(학습 데이터 범위 내)
- **Compositor 노드**: 후처리 체인을 위한 `Compositor` + `CompositorEffect`

## 현재 API 패턴

### 후처리 (4.3+)
```gdscript
# 수동 뷰포트 셰이더 체인이 아니라 Compositor 노드를 사용할 것
# WorldEnvironment 또는 Camera3D의 자식으로 Compositor를 추가
# 각 후처리 단계마다 CompositorEffect 리소스를 생성
```

### 안티앨리어싱 옵션 (4.6)
```
Project Settings → Rendering → Anti Aliasing:
- MSAA 2D/3D: 하드웨어 MSAA(품질은 좋지만 비용이 큼)
- Screen Space AA: FXAA(빠르지만 흐릿함) 또는 SMAA(선명하고 비용이 중간 정도)  # SMAA는 4.5 신규
- TAA: 시간적(Temporal) 안티앨리어싱(품질은 최고지만 빠른 움직임에서 고스팅 발생)
```

### 렌더링 백엔드 선택 (4.6)
```
Project Settings → Rendering → Renderer:
- Forward+ (기본값): 모든 기능을 갖춘, 데스크톱 중심
- Mobile: 모바일/저사양 기기에 최적화, 기능 제한
- Compatibility: OpenGL 3.3 / WebGL 2, 가장 넓은 하드웨어 호환성

Windows 기본 백엔드: D3D12(4.6 이전에는 Vulkan)
```

## 흔한 실수
- Windows에서 Vulkan이 기본 백엔드라고 가정하는 것(4.6부터는 D3D12)
- 후처리에 Compositor 대신 수동 뷰포트 체인을 사용하는 것
- 셰이더 유니폼 타입에 `Texture2D`를 사용하는 것(4.4부터는 `Texture`를 사용할 것)
- 셰이더 변형이 많은 프로젝트에서 셰이더 베이커를 사용하지 않는 것
