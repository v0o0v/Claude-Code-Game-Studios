# Godot 내비게이션 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.5 변경 사항
- **전용 2D 내비게이션 서버**: 더 이상 3D NavigationServer의 프록시가 아니다
  - 2D 전용 게임의 익스포트 바이너리 크기가 줄어든다
  - API는 2D와 3D 모두 동일하게 유지된다

### 4.3 변경 사항(학습 데이터 범위 내)
- **`NavigationRegion2D`**: `avoidance_layers`, `constrain_avoidance` 속성이 제거됨

## 현재 API 패턴

### NavigationAgent3D (대부분의 경우에 권장)
```gdscript
@onready var nav_agent: NavigationAgent3D = %NavigationAgent3D

func _ready() -> void:
    nav_agent.path_desired_distance = 0.5
    nav_agent.target_desired_distance = 1.0
    nav_agent.velocity_computed.connect(_on_velocity_computed)

func navigate_to(target: Vector3) -> void:
    nav_agent.target_position = target

func _physics_process(delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return
    var next_pos: Vector3 = nav_agent.get_next_path_position()
    var direction: Vector3 = global_position.direction_to(next_pos)
    nav_agent.velocity = direction * move_speed

func _on_velocity_computed(safe_velocity: Vector3) -> void:
    velocity = safe_velocity
    move_and_slide()
```

### NavigationAgent2D
```gdscript
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D

func navigate_to(target: Vector2) -> void:
    nav_agent.target_position = target

func _physics_process(delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return
    var next_pos: Vector2 = nav_agent.get_next_path_position()
    var direction: Vector2 = global_position.direction_to(next_pos)
    velocity = direction * move_speed
    move_and_slide()
```

### 저수준 경로 쿼리 (3D)
```gdscript
# 커스텀 경로 탐색 로직을 위한 서버 직접 쿼리
var query := NavigationPathQueryParameters3D.new()
query.map = get_world_3d().navigation_map
query.start_position = global_position
query.target_position = target_pos
query.navigation_layers = navigation_layers

var result := NavigationPathQueryResult3D.new()
NavigationServer3D.query_path(query, result)
var path: PackedVector3Array = result.path
```

### 회피(Avoidance)
```gdscript
# RVO2 기반 로컬 회피 활성화
nav_agent.avoidance_enabled = true
nav_agent.radius = 0.5
nav_agent.max_speed = move_speed
nav_agent.neighbor_distance = 10.0

# 회피 안전 이동을 위해 velocity_computed 시그널을 사용
nav_agent.velocity_computed.connect(_on_velocity_computed)

# 매 프레임 velocity를 설정(회피 기능에 필요)
nav_agent.velocity = desired_velocity
```

### 내비게이션 레이어
```gdscript
# 레이어를 사용해 에이전트 타입별로 이동 가능 영역을 분리한다
# 레이어 1: 지상 유닛
# 레이어 2: 비행 유닛
# 레이어 3: 수영 유닛
nav_agent.navigation_layers = 1  # 지상 전용
nav_agent.navigation_layers = 1 | 2  # 지상 + 비행
```

## 흔한 실수
- `is_navigation_finished()`를 확인하지 않고 `get_next_path_position()`을 호출하는 것
- 회피가 활성화되어 있을 때 에이전트에 `velocity`를 설정하지 않는 것(RVO2에 필요)
- `NavigationRegion2D.avoidance_layers`를 사용하는 것(4.3에서 제거됨)
- 지오메트리 수정 후 내비게이션 메시를 베이크하는 것을 잊는 것
- `navigation_layers`를 설정하지 않는 것(기본값은 모든 레이어)
