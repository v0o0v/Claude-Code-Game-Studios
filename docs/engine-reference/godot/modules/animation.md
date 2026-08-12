# Godot 애니메이션 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.6 변경 사항
- **IK 시스템 완전 복원**: 3D 스켈레톤을 위한 완전한 역기구학
  - CCDIK, FABRIK, Jacobian IK, Spline IK, TwoBoneIK
  - `SkeletonModifier3D` 노드를 통해 적용된다(기존 IK 방식이 아님)
- **애니메이션 에디터 QoL**: Bezier 노드 그룹의 솔로/숨김/잠금/삭제; 드래그 가능한 타임라인

### 4.5 변경 사항
- **BoneConstraint3D**: 모디파이어를 통해 뼈(bone)를 다른 뼈에 결합
  - `AimModifier3D`, `CopyTransformModifier3D`, `ConvertTransformModifier3D`

### 4.3 변경 사항(학습 데이터 범위 내)
- **AnimationMixer**: AnimationPlayer와 AnimationTree 양쪽의 기반 클래스
  - `method_call_mode` → `callback_mode_method`
  - `playback_active` → `active`
  - `bone_pose_updated` 시그널 → `skeleton_updated`
- **`Skeleton3D.add_bone()`**: 이제 `int32`를 반환(이전에는 `void`)

## 현재 API 패턴

### AnimationPlayer (API는 동일, 기반 클래스만 변경)
```gdscript
@onready var anim_player: AnimationPlayer = %AnimationPlayer

func play_attack() -> void:
    anim_player.play(&"attack")
    await anim_player.animation_finished
```

### IK 설정 (4.6 — 신규)
```gdscript
# SkeletonModifier3D 기반 IK 노드를 Skeleton3D의 자식으로 추가한다
# 사용 가능한 타입:
# - SkeletonModifier3D (기반)
# - TwoBoneIK (팔, 다리)
# - FABRIK (체인, 촉수)
# - CCDIK (꼬리, 척추)
# - Jacobian IK (복잡한 다중 관절)
# - Spline IK (곡선을 따라가는 경우)

# 에디터 또는 코드로 구성:
# 1. Skeleton3D의 자식으로 IK 모디파이어 노드를 추가한다
# 2. 타깃 뼈와 팁(tip) 뼈를 설정한다
# 3. IK 타깃으로 Marker3D를 추가한다
# 4. IK 솔버가 매 프레임 자동으로 실행된다
```

### BoneConstraint3D (4.5 — 신규)
```gdscript
# Skeleton3D의 자식으로 추가
# 타입:
# - AimModifier3D: 뼈가 타깃을 향하도록 함
# - CopyTransformModifier3D: 다른 뼈의 트랜스폼을 미러링
# - ConvertTransformModifier3D: 트랜스폼 값을 재매핑
```

### AnimationTree (4.3에서 기반 클래스 변경)
```gdscript
# AnimationTree는 이제 Node를 직접 상속하지 않고 AnimationMixer를 상속한다
# AnimationMixer의 속성을 사용할 것:
@onready var anim_tree: AnimationTree = %AnimationTree

func _ready() -> void:
    anim_tree.active = true  # playback_active가 아님(4.3에서 사용 중단)
```

## 흔한 실수
- `active` 대신 `playback_active`를 사용하는 것(4.3부터 사용 중단)
- `skeleton_updated` 대신 `bone_pose_updated` 시그널을 사용하는 것(4.3에서 이름 변경)
- SkeletonModifier3D 시스템(4.6에서 복원됨) 대신 예전 IK 방식을 사용하는 것
- 애니메이션 노드를 타입 체크할 때 `is AnimationMixer`를 확인하지 않는 것
