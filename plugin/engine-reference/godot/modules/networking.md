# Godot 네트워킹 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

### 4.6 변경 사항
- **breaking changes 문서의 네트워킹 섹션**: 4.5→4.6 수준의 세부 내용은
  공식 마이그레이션 가이드를 참고할 것

### 4.5 변경 사항
- **주요 네트워킹 API 변경 없음** — 핵심 멀티플레이어 API는 안정적으로 유지된다

## 현재 API 패턴

### 고수준 멀티플레이어
```gdscript
# 서버
func host_game(port: int = 9999) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# 클라이언트
func join_game(address: String, port: int = 9999) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_client(address, port)
    multiplayer.multiplayer_peer = peer
```

### RPC
```gdscript
# 서버 권위(server-authoritative) 패턴
@rpc("any_peer", "call_local", "reliable")
func request_action(action_data: Dictionary) -> void:
    if not multiplayer.is_server():
        return
    # 서버에서 검증한 뒤 브로드캐스트한다
    _execute_action.rpc(action_data)

@rpc("authority", "call_local", "reliable")
func _execute_action(action_data: Dictionary) -> void:
    # 모든 피어가 검증된 액션을 실행한다
    pass
```

### MultiplayerSpawner와 MultiplayerSynchronizer
```gdscript
# 노드 자동 복제에는 MultiplayerSpawner를 사용한다
# 속성 동기화에는 MultiplayerSynchronizer를 사용한다

# MultiplayerSynchronizer 설정:
# 1. 동기화할 노드의 자식으로 추가한다
# 2. 에디터에서 복제할 속성을 구성한다
# 3. 연관성(relevancy)을 위한 가시성 필터를 설정한다
```

### SceneMultiplayer 구성
```gdscript
func _ready() -> void:
    var scene_mp := multiplayer as SceneMultiplayer
    scene_mp.auth_callback = _authenticate_peer
    scene_mp.server_relay = false  # 피어 간 직접 연결

func _authenticate_peer(id: int, data: PackedByteArray) -> void:
    # 커스텀 인증 로직
    pass
```

## 흔한 실수
- 클라이언트→서버 RPC에 `"any_peer"`를 사용하지 않는 것(기본값은 authority 전용)
- 서버 측 검증 없이 클라이언트 데이터를 신뢰하는 것
- 게임 상태 변경에 `"unreliable"`을 사용하는 것(위치 업데이트 전용으로만 쓸 것)
- 스폰된 노드에 멀티플레이어 권한(`set_multiplayer_authority()`)을 설정하지 않는 것
