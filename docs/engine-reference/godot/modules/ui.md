# Godot UI — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.6 변경 사항
- **듀얼 포커스 시스템**: 마우스/터치 포커스가 이제 키보드/게임패드 포커스와 완전히 분리된다
  - 입력 방식에 따라 시각적 피드백이 달라진다
  - 커스텀 포커스 구현은 업데이트가 필요할 수 있다
- **TabContainer**: 탭 속성을 Inspector에서 직접 편집할 수 있다
- **TileMapLayer 씬 타일 회전**: 씬 타일도 아틀라스 타일처럼 회전시킬 수 있다

### 4.5 변경 사항
- **FoldableContainer**: 접고 펼칠 수 있는 섹션을 위한 새로운 아코디언 스타일 UI 노드
- **재귀적 Control 동작**: 속성 하나로 노드 계층 전체의 마우스/포커스를 비활성화할 수 있다
- **스크린 리더 지원**: Control 노드가 AccessKit와 연동된다
- **실시간 번역 미리보기**: 에디터에서 바로 여러 로케일을 테스트할 수 있다
- **`RichTextLabel.push_meta`**: 선택적 `tooltip` 파라미터 추가(4.4부터)

### 4.4 변경 사항
- **`GraphEdit.connect_node`**: 선택적 `keep_alive` 파라미터 추가

## 현재 API 패턴

### 테마와 스타일 (4.6)
```gdscript
# 에디터는 기본적으로 새로운 "Modern" 테마를 사용한다
# 게임 UI의 경우, 이전과 동일하게 커스텀 테마를 사용할 것:
var theme := Theme.new()
theme.set_color(&"font_color", &"Label", Color.WHITE)
theme.set_font_size(&"font_size", &"Label", 24)
```

### 포커스 관리 (4.6 — 변경됨)
```gdscript
# 키보드/게임패드 포커스(grab_focus는 여전히 동작한다)
func _ready() -> void:
    %StartButton.grab_focus()

# 중요: 4.6에서는 마우스 호버가 키보드 포커스와 분리되어 있다
# 서로 다른 컨트롤에서 두 가지가 동시에 활성화될 수 있다
# UI를 마우스와 키보드/게임패드 둘 다로 테스트할 것

# 포커스 이웃(neighbor) (변경 없음)
%Button1.focus_neighbor_bottom = %Button2.get_path()
%Button1.focus_neighbor_right = %Button3.get_path()
```

### FoldableContainer (4.5 — 신규)
```gdscript
# 접고 펼칠 수 있는 아코디언 스타일 컨테이너
# 접을 수 있게 하고 싶은 콘텐츠의 부모로 추가한다
# 헤더를 클릭하면 자식들이 표시/숨김 처리된다
# 에디터 속성 또는 코드로 구성한다
```

### 재귀적 비활성화 (4.5 — 신규)
```gdscript
# 계층 전체의 마우스/포커스 상호작용을 비활성화한다
# 메뉴 섹션 전체를 비활성화할 때 유용하다
%SettingsPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
# 4.5+에서는 이것이 자식들에게 재귀적으로 전파될 수 있다
```

### 지역화 대비 UI (모범 사례)
```gdscript
# 화면에 표시되는 모든 문자열에 tr()을 사용할 것
label.text = tr("MENU_START_GAME")

# 라벨에는 auto-wrap을 사용할 것(언어에 따라 텍스트 길이가 달라진다)
label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

# 에디터의 실시간 번역 미리보기로 테스트할 것(4.5+)
```

## 흔한 실수
- `grab_focus()`가 마우스 포커스에도 영향을 준다고 가정하는 것(4.6에서는 키보드/게임패드에만 영향)
- 4.6으로 업그레이드한 후 마우스와 게임패드 양쪽으로 UI를 테스트하지 않는 것
- 지역화를 위해 `tr()`을 사용하지 않고 문자열을 하드코딩하는 것
- 접고 펼칠 수 있는 UI에 `FoldableContainer`를 사용하지 않는 것(4.5 신규, 커스텀 구현보다 깔끔함)
