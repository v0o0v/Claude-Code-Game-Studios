# Godot — 사용 중단된 API

최종 검증일: 2026-02-12

에이전트가 "Deprecated" 열에 있는 API를 제안한다면, 반드시
"Use Instead" 열의 API로 교체해야 한다.

## 노드 & 클래스

| 사용 중단 | 대신 사용 | 시점 | 비고 |
|------------|-------------|-------|-------|
| `TileMap` | `TileMapLayer` | 4.3 | 다중 레이어 노드 대신 레이어당 하나의 노드 |
| `VisibilityNotifier2D` | `VisibleOnScreenNotifier2D` | 4.0 | 명확성을 위해 이름 변경 |
| `VisibilityNotifier3D` | `VisibleOnScreenNotifier3D` | 4.0 | 명확성을 위해 이름 변경 |
| `YSort` | `Node2D.y_sort_enabled` | 4.0 | 별도 노드가 아니라 Node2D의 속성이다 |
| `Navigation2D` / `Navigation3D` | `NavigationServer2D` / `NavigationServer3D` | 4.0 | 서버 기반 API |
| `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF` | 4.3 | 이름 변경 |

## 메서드 & 속성

| 사용 중단 | 대신 사용 | 시점 | 비고 |
|------------|-------------|-------|-------|
| `yield()` | `await signal` | 4.0 | GDScript 2.0 코루틴 문법 |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 | Callable 기반 연결 |
| `instance()` | `instantiate()` | 4.0 | 이름 변경 |
| `PackedScene.instance()` | `PackedScene.instantiate()` | 4.0 | 이름 변경 |
| `get_world()` | `get_world_3d()` | 4.0 | 2D/3D 명시적 분리 |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 | Time 싱글턴을 권장 |
| 중첩 리소스에 `duplicate()` | `duplicate_deep()` | 4.5 | 명시적인 깊은 복사(deep copy) 제어 |
| `Skeleton3D`의 `bone_pose_updated` 시그널 | `skeleton_updated` | 4.3 | 이름 변경 |
| `AnimationPlayer.method_call_mode` | `AnimationMixer.callback_mode_method` | 4.3 | 기반 클래스로 이동 |
| `AnimationPlayer.playback_active` | `AnimationMixer.active` | 4.3 | 기반 클래스로 이동 |

## 패턴 (단순 API가 아닌 관행)

| 사용 중단된 패턴 | 대신 사용 | 이유 |
|--------------------|-------------|-----|
| 문자열 기반 `connect()` | 타입이 지정된 시그널 연결 | 타입 안전성, 리팩터링 용이성 |
| `_process()`에서 `$NodePath` | `@onready var`로 캐시된 참조 | 성능: 매 프레임 경로 조회는 비효율적 |
| 타입이 지정되지 않은 `Array` / `Dictionary` | `Array[Type]`, 타입이 지정된 변수 | GDScript 컴파일러 최적화 |
| 셰이더 파라미터의 `Texture2D` | `Texture` 기반 타입 | 4.4에서 변경됨 |
| 수동 후처리 뷰포트 체인 | `Compositor` + `CompositorEffect` | 구조화된 후처리(4.3+) |
| 신규 프로젝트에서 GodotPhysics3D | Jolt Physics 3D | 4.6부터 기본값; 안정성이 더 좋음 |
