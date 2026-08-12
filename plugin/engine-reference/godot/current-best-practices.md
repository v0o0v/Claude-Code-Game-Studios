# Godot — 현재 모범 사례

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

모델의 학습 데이터(~4.3) 이후 **새로 생겼거나 변경된** 관행들이다.
이는 에이전트가 이미 갖고 있는 지식을 대체하는 것이 아니라 보완하는 것이다.

## GDScript (4.5+)

- **가변 인자**: 함수가 임의 개수의 파라미터를 받을 수 있다
  ```gdscript
  func log_values(prefix: String, values: Variant...) -> void:
      for v in values:
          print(prefix, ": ", v)
  ```

- **추상 클래스와 추상 메서드**: 상속을 강제하려면 `@abstract`를 사용한다
  ```gdscript
  @abstract
  class_name BaseEnemy extends CharacterBody3D

  @abstract
  func get_attack_pattern() -> Array[Attack]:
      pass  # 서브클래스가 반드시 오버라이드해야 한다
  ```

- **스크립트 백트레이싱**: Release 빌드에서도 상세한 콜 스택을 확인할 수 있다

## Physics (4.6)

- **Jolt Physics가 신규 프로젝트의 기본 3D 엔진이다**
  - GodotPhysics3D보다 결정론성과 안정성이 우수하다
  - 일부 HingeJoint3D 속성(`damp`)은 GodotPhysics에서만 동작한다
  - 전환: Project Settings → Physics → 3D → Physics Engine
  - 2D 물리는 변경되지 않았다(여전히 Godot Physics 2D)

## Rendering (4.6)

- **Windows에서 D3D12가 기본 백엔드다**(이전에는 Vulkan) — 드라이버 호환성 향상을 위한 변경
- **Glow가 이제 톤매핑 이전에 처리된다**(screen 블렌딩 모드 사용) — 기존 glow 설정은 다르게 보일 수 있다
- **SSR이 전면 개편되었다** — 사실감, 안정성, 성능이 크게 향상되었다
- **AgX 톤매퍼** — 화이트 포인트 및 콘트라스트 컨트롤 신규 추가

## Rendering (4.5)

- **셰이더 베이커**: 셰이더를 사전 컴파일하여 시작 시 끊김(hitching)을 제거한다
- **SMAA 1x**: 새로운 AA 옵션 — FXAA보다 선명하고, TAA보다 저렴하다
- **스텐실 버퍼**: 고급 마스킹/포털 이펙트에 사용 가능
- **벤트 노멀 맵**: 노멀 맵 텍스처에 방향성 오클루전을 인코딩
- **스페큘러 오클루전**: 앰비언트 오클루전이 이제 반사에도 정확히 반영된다

## Accessibility (4.5+)

- **스크린 리더 지원**: Control 노드가 AccessKit를 통해 접근성 도구와 연동된다
- **실시간 번역 미리보기**: 에디터에서 바로 다양한 언어로 GUI 레이아웃을 테스트할 수 있다
- **FoldableContainer**: 접고 펼칠 수 있는 섹션을 위한 새로운 아코디언 스타일 UI 노드
- **재귀적 Control 비활성화**: 속성 하나로 노드 계층 전체의 마우스/포커스 상호작용을 비활성화할 수 있다

## Animation (4.5+)

- **BoneConstraint3D**: 모디파이어를 통해 뼈(bone)를 다른 뼈에 결합한다
  - AimModifier3D, CopyTransformModifier3D, ConvertTransformModifier3D

## Animation (4.6)

- **IK 시스템 완전 복원**: 3D를 위한 완전한 역기구학(inverse kinematics)이 재도입되었다
  - 사용 가능한 모디파이어: CCDIK, FABRIK, Jacobian IK, Spline IK, TwoBoneIK
  - `SkeletonModifier3D` 노드를 통해 적용된다

## Resources (4.5+)

- **`duplicate_deep()`**: 중첩된 리소스 트리를 명시적으로 깊은 복제(deep duplication)한다
  - 기존 `duplicate()`의 동작은 하위 호환을 위해 그대로 유지된다
  - 중첩 리소스의 인스턴스별 사본이 필요할 때 `duplicate_deep()`을 사용할 것

## Navigation (4.5+)

- **전용 2D 내비게이션 서버**: 더 이상 3D NavigationServer를 통해 프록시되지 않는다
  - 2D 전용 게임의 익스포트 바이너리 크기가 줄어든다

## UI (4.6)

- **듀얼 포커스 시스템**: 마우스/터치 포커스가 이제 키보드/게임패드 포커스와 분리된다
  - 입력 방식에 따라 시각적 피드백이 달라진다
  - 커스텀 포커스 동작을 설계할 때 이 점을 고려할 것

## Editor Workflow (4.6)

- 파란색 윤곽선 미리보기가 있는 유연한 독 드래그 앤 드롭(하단 패널 포함)
- 대부분의 패널이 플로팅 창을 지원한다(Debugger는 예외)
- 새 단축키: Alt+O(Output), Alt+S(Shader)
- Export 변수 자동 생성: FileSystem에서 스크립트 에디터로 리소스를 드래그
- "Live Preview"가 활성화된 경우 Quick Open 다이얼로그에서 실시간 미리보기
- 새로운 "Select Mode"(v 키)는 의도치 않은 트랜스폼을 방지한다; 기존 모드는 "Transform Mode"(q 키)로 이름이 변경되었다

## Tooling

- **ripgrep에는 `gdscript` 타입이 없다**: `*.gd`는 `gap`(GAP 프로그래밍 언어) 아래에 등록되어 있다.
  `rg --type gdscript`는 하드 에러를 발생시킨다 — 검색이 아예 실행되지 않는다.
  항상 `rg --glob "*.gd"`(셸) 또는 `glob: "*.gd"`(Grep 도구)를 사용해 GDScript 파일을 필터링할 것.

## Platform (4.5+)

- **visionOS 익스포트**: 오픈소스화 이후 처음 추가된 신규 플랫폼(윈도우 앱 모드)
- **SDL3 게임패드 드라이버**: 더 나은 크로스 플랫폼 게임패드 지원
- **Android**: 엣지 투 엣지 디스플레이, 카메라 피드 접근, 16KB 페이지 지원(Android 15+)
- **Linux**: 멀티 윈도우를 위한 Wayland 서브윈도우 지원
