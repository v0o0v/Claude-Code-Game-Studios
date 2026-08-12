# Godot 입력 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.6 변경 사항
- **듀얼 포커스 시스템**: 마우스/터치 포커스가 이제 키보드/게임패드 포커스와 분리된다
  - 입력 방식에 따라 시각적 피드백이 달라진다
  - 커스텀 포커스 구현은 업데이트가 필요할 수 있다
- **Select Mode 단축키 변경**: "Select Mode"가 이제 `v` 키다; 기존 모드는 "Transform Mode"(`q` 키)로 이름이 변경되었다

### 4.5 변경 사항
- **SDL3 게임패드 드라이버**: 더 나은 크로스 플랫폼 지원을 위해 게임패드 처리가 SDL 라이브러리에 위임되었다
- **재귀적 Control 비활성화**: 속성 하나로 노드 계층 전체의 마우스/포커스를 비활성화할 수 있다

### 4.3 변경 사항(학습 데이터 범위 내)
- **InputEventShortcut**: 메뉴 단축키를 위한 전용 이벤트 타입(선택 사항)

## 현재 API 패턴

### 입력 액션 (변경 없음)
```gdscript
func _physics_process(delta: float) -> void:
    var input_dir: Vector2 = Input.get_vector(
        &"move_left", &"move_right", &"move_forward", &"move_back"
    )
    if Input.is_action_just_pressed(&"jump"):
        jump()
```

### 입력 이벤트 (변경 없음)
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_click(event.position)
    elif event is InputEventKey:
        if event.keycode == KEY_ESCAPE and event.pressed:
            toggle_pause()
```

### 포커스 관리 (4.6 — 변경됨)
```gdscript
# 마우스/터치 포커스와 키보드/게임패드 포커스가 이제 서로 분리되어 있다
# 어떤 입력 방식이 활성화되어 있는지에 따라 시각적 스타일이 다를 수 있다
# 커스텀 포커스 드로잉이 있다면 두 입력 방식 모두로 테스트할 것

# 표준적인 접근 방식은 여전히 동작한다:
func _ready() -> void:
    %StartButton.grab_focus()  # 키보드/게임패드 포커스

# 단, 4.6에서는 마우스 호버 포커스 != 키보드 포커스라는 점을 유의할 것
```

### 게임패드 (4.5+ — SDL3 백엔드)
```gdscript
# API는 변경되지 않았지만 SDL3가 다음을 제공한다:
# - 플랫폼 간 더 나은 장치 감지
# - 개선된 진동(rumble) 지원
# - 더 일관된 버튼 매핑

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton:
        if event.button_index == JOY_BUTTON_A and event.pressed:
            confirm_selection()
```

## 흔한 실수
- 마우스와 키보드 포커스 경로를 둘 다 테스트하지 않는 것(4.6의 듀얼 포커스)
- `grab_focus()`가 마우스 포커스에도 영향을 준다고 가정하는 것(4.6에서는 키보드/게임패드에만 영향)
- 핫 패스에서 액션 이름에 `StringName`(`&"action"`) 대신 문자열 리터럴을 사용하는 것
