# Godot — 주요 변경 사항(Breaking Changes)

최종 검증일: 2026-02-12

LLM 지식 컷오프 이후에 발생한 변경 사항(4.4+)을 중심으로 정리한 Godot 버전 간 변경점.

## 4.5 → 4.6 (2026년 1월 — 컷오프 이후, 고위험)

| 서브시스템 | 변경 사항 | 세부 내용 |
|-----------|--------|---------|
| Physics | Jolt가 이제 기본(DEFAULT) 3D 물리 엔진 | 신규 프로젝트는 자동으로 Jolt를 사용한다. 기존 프로젝트는 기존 설정을 유지한다. 일부 HingeJoint3D 속성(예: `damp`)은 GodotPhysics에서만 동작한다. |
| Rendering | Glow가 톤매핑 이전(BEFORE)에 처리됨 | 이전에는 톤매핑 이후였다. glow를 쓰는 씬은 다르게 보일 수 있다. WorldEnvironment에서 강도/블렌드를 조정할 것. |
| Rendering | Windows에서 D3D12가 기본값 | 이전에는 Vulkan이었다. 드라이버 호환성 향상을 위한 변경. |
| Rendering | AgX 톤매퍼에 새 컨트롤 추가 | 화이트 포인트 및 콘트라스트 파라미터가 추가되었다. |
| Core | Quaternion이 항등원(identity)으로 초기화됨 | 이전에는 영(zero)이었다. 대부분의 코드에는 영향이 없을 가능성이 높지만 기술적으로는 호환성이 깨진다. |
| UI | 듀얼 포커스 시스템 | 마우스/터치 포커스가 이제 키보드/게임패드 포커스와 분리된다. 입력 방식에 따라 시각적 피드백이 달라진다. |
| Animation | IK 시스템 완전 복원 | SkeletonModifier3D 노드를 통한 CCDIK, FABRIK, Jacobian IK, Spline IK, TwoBoneIK. |
| Editor | 새로운 "Modern" 테마가 기본값 | 그레이스케일이 블루 틴트를 대체한다. 복원 방법: Editor Settings → Interface → Theme → Style: Classic |
| Editor | "Select Mode" 단축키 변경 | 새로운 "Select Mode"(v 키)는 의도치 않은 트랜스폼을 방지한다. 기존 모드는 "Transform Mode"(q 키)로 이름이 변경되었다. |
| 2D | TileMapLayer 씬 타일 회전 | 씬 타일도 이제 아틀라스 타일처럼 회전시킬 수 있다. |
| Localization | CSV 복수형(plural) 지원 | 복수형 처리에 더 이상 Gettext가 필요하지 않다. 컨텍스트 컬럼이 추가되었다. |
| C# | 자동 문자열 추출 | 번역 문자열이 C# 코드에서 자동 추출된다. |
| Plugins | 새로운 EditorDock 클래스 | 레이아웃 제어가 가능한, 플러그인 독을 위한 전용 컨테이너. |

## 4.4 → 4.5 (2025년 후반 — 컷오프 이후, 고위험)

| 서브시스템 | 변경 사항 | 세부 내용 |
|-----------|--------|---------|
| GDScript | 가변 인자(variadic arguments) 추가 | 함수가 `...`로 임의 개수의 파라미터를 받을 수 있다 — 새로운 언어 기능 |
| GDScript | `@abstract` 데코레이터 | 추상 클래스와 추상 메서드를 이제 강제할 수 있다 |
| GDScript | 스크립트 백트레이싱 | Release 빌드에서도 상세한 콜 스택을 확인할 수 있다 |
| Rendering | 스텐실 버퍼 지원 | 고급 비주얼 이펙트를 위한 새 기능 |
| Rendering | SMAA 1x 안티앨리어싱 | 새로운 후처리 AA 옵션 |
| Rendering | 셰이더 베이커(Shader Baker) | 셰이더를 사전 컴파일한다 — 일부 데모에서 시작 속도가 20배 빨라졌다는 보고가 있다 |
| Rendering | 벤트 노멀 맵, 스페큘러 오클루전 | 새로운 머티리얼 기능 |
| Accessibility | 스크린 리더 지원 | AccessKit를 통해 Control 노드가 접근성 도구와 연동된다 |
| Editor | 실시간 번역 미리보기 | 에디터 내에서 다양한 언어로 GUI 레이아웃을 테스트할 수 있다 |
| Physics | 3D 보간(interpolation) 재설계 | RenderingServer에서 SceneTree로 이동했다. API는 동일하지만 내부 동작은 다르다. |
| Animation | BoneConstraint3D | 신규: AimModifier3D, CopyTransformModifier3D, ConvertTransformModifier3D |
| Resources | `duplicate_deep()` 추가 | 중첩된 리소스를 깊은 복제(deep duplication)하기 위한 새로운 명시적 메서드 |
| Navigation | 전용 2D 내비게이션 서버 | 더 이상 3D 내비게이션의 프록시가 아니다. 2D 게임의 익스포트 용량이 줄어든다 |
| UI | FoldableContainer 노드 | 접고 펼칠 수 있는 UI 섹션을 위한 새로운 아코디언 스타일 컨테이너 |
| UI | 재귀적 Control 동작 | 노드 계층 전체에 걸쳐 마우스/포커스 상호작용을 비활성화할 수 있다 |
| Platform | visionOS 익스포트 지원 | 새로운 플랫폼 타깃 |
| Platform | SDL3 게임패드 드라이버 | 게임패드 처리를 SDL 라이브러리에 위임 |
| Platform | Android 16KB 페이지 지원 | Android 15+를 타깃하는 Google Play에 필수 |

## 4.3 → 4.4 (2025년 중반 — 컷오프 근접, 확인 필요)

| 서브시스템 | 변경 사항 | 세부 내용 |
|-----------|--------|---------|
| Core | `FileAccess.store_*`가 `bool`을 반환 | 이전에는 `void`였다. 대상 메서드: `store_8`, `store_16`, `store_32`, `store_64`, `store_buffer`, `store_csv_line`, `store_double`, `store_float`, `store_half`, `store_line`, `store_pascal_string`, `store_real`, `store_string`, `store_var` |
| Core | `OS.execute_with_pipe` | 선택적 `blocking` 파라미터 추가 |
| Core | `RegEx.compile/create_from_string` | 선택적 `show_error` 파라미터 추가 |
| Rendering | `RenderingDevice.draw_list_begin` | 다수의 파라미터가 제거됨; `breadcrumb` 파라미터 추가 |
| Rendering | 셰이더 텍스처 타입 | 파라미터/반환 타입이 `Texture2D`에서 `Texture`로 변경됨 |
| Particles | `.restart()` 메서드 | 선택적 `keep_seed` 파라미터 추가(CPU/GPU 2D/3D) |
| GUI | `RichTextLabel.push_meta` | 선택적 `tooltip` 파라미터 추가 |
| GUI | `GraphEdit.connect_node` | 선택적 `keep_alive` 파라미터 추가 |

## 4.2 → 4.3 (학습 데이터 범위 내 — 저위험)

| 서브시스템 | 변경 사항 | 세부 내용 |
|-----------|--------|---------|
| Animation | `Skeleton3D.add_bone`이 `int32`를 반환 | 이전에는 `void`였다 |
| Animation | `bone_pose_updated` 시그널 | `skeleton_updated`로 대체됨 |
| TileMap | `TileMapLayer`가 `TileMap`을 대체 | 다중 레이어 단일 노드 대신 레이어당 하나의 노드 |
| Navigation | `NavigationRegion2D` | `avoidance_layers`, `constrain_avoidance` 속성 제거됨 |
| Editor | `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF`로 이름 변경 |
| Animation | AnimationMixer 기반 클래스 | AnimationPlayer와 AnimationTree가 이제 AnimationMixer를 상속한다 |
