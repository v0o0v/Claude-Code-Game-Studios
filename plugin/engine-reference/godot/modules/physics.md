# Godot 물리 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.6 변경 사항
- **Jolt Physics가 신규 프로젝트의 기본(DEFAULT) 3D 엔진이다**
  - 기존 프로젝트는 현재의 물리 엔진 설정을 그대로 유지한다
  - GodotPhysics3D보다 결정론성, 안정성, 성능이 더 우수하다
  - 일부 HingeJoint3D 속성(`damp`)은 GodotPhysics3D에서만 동작한다
  - 2D 물리는 변경되지 않았다(여전히 Godot Physics 2D)

### 4.5 변경 사항
- **3D 물리 보간(interpolation) 재설계**: RenderingServer에서 SceneTree로 이동했다
  - 사용자 대상 API는 동일하지만, 예외적인 경우 내부 동작이 다를 수 있다

## 물리 엔진 선택 (4.6)

```
Project Settings → Physics → 3D → Physics Engine:
- Jolt Physics (신규 프로젝트 기본값)
- GodotPhysics3D (레거시, 여전히 사용 가능)
```

### Jolt vs GodotPhysics3D

| 특성 | Jolt(기본값) | GodotPhysics3D |
|---------|---------------|----------------|
| 결정론성 | 더 우수함 | 일관성이 떨어짐 |
| 안정성 | 더 우수함 | 적정 수준 |
| 성능 | 복잡한 씬에서 더 우수함 | 적정 수준 |
| HingeJoint3D `damp` | 지원 안 함 | 지원함 |
| 런타임 경고 | 지원되지 않는 속성에 대해 경고함 | 경고 없음 |
| 충돌 마진 | 동작이 다를 수 있음 | 기존 동작 그대로 |

## 현재 API 패턴

### 기본 물리 설정 (변경 없음)
```gdscript
# CharacterBody3D 이동 — 엔진과 무관하게 API는 동일
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
    var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    move_and_slide()
```

### 레이캐스팅 (변경 없음)
```gdscript
var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
var query := PhysicsRayQueryParameters3D.create(from, to)
query.collision_mask = collision_mask
var result: Dictionary = space_state.intersect_ray(query)
if result:
    var hit_point: Vector3 = result.position
    var hit_normal: Vector3 = result.normal
```

## 흔한 실수
- GodotPhysics3D가 기본값이라고 가정하는 것(4.6부터는 Jolt가 기본값)
- 물리 엔진을 확인하지 않고 HingeJoint3D `damp` 속성을 사용하는 것(Jolt는 이 속성을 무시한다)
- 물리 엔진을 전환할 때 충돌 관련 예외 케이스를 테스트하지 않는 것
