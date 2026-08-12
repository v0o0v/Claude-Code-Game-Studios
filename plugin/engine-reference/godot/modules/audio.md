# Godot 오디오 — 빠른 레퍼런스

최종 검증일: 2026-02-12 | 엔진: Godot 4.6

## ~4.3(LLM 컷오프) 이후 변경된 사항

4.4–4.6에서 오디오 API에는 주요 호환성 파괴 변경 사항이 없었다. 핵심 오디오 시스템은
안정적으로 유지되고 있다. 주요 업데이트는 워크플로 개선에 관한 것들이다.

### 4.6 변경 사항
- 이번 릴리스에 **오디오 관련 호환성 파괴 변경 사항 없음**

### 4.5 변경 사항
- 이번 릴리스에 **오디오 관련 호환성 파괴 변경 사항 없음**

## 현재 API 패턴

### 오디오 재생
```gdscript
@onready var sfx_player: AudioStreamPlayer = %SFXPlayer
@onready var music_player: AudioStreamPlayer = %MusicPlayer

func play_sfx(stream: AudioStream) -> void:
    sfx_player.stream = stream
    sfx_player.play()

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
    var tween: Tween = create_tween()
    tween.tween_property(music_player, "volume_db", -80.0, fade_time)
    await tween.finished
    music_player.stream = stream
    music_player.volume_db = 0.0
    music_player.play()
```

### 3D 공간 오디오
```gdscript
@onready var audio_3d: AudioStreamPlayer3D = %AudioPlayer3D

func _ready() -> void:
    audio_3d.max_distance = 50.0
    audio_3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
    audio_3d.unit_size = 10.0
```

### 오디오 버스
```gdscript
# 버스 볼륨 설정
AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), volume_db)
AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"), volume_db)

# 버스 음소거
AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Music"), true)
```

### SFX용 오브젝트 풀링
```gdscript
# 동시 재생되는 사운드를 위해 여러 AudioStreamPlayer 노드를 미리 생성해 둔다
var _sfx_pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
    for i in range(8):
        var player := AudioStreamPlayer.new()
        player.bus = &"SFX"
        add_child(player)
        _sfx_pool.append(player)

func play_pooled(stream: AudioStream) -> void:
    for player in _sfx_pool:
        if not player.playing:
            player.stream = stream
            player.play()
            return
```

## 흔한 실수
- 풀링하지 않고 런타임에 AudioStreamPlayer 노드를 계속 새로 생성하는 것
- 볼륨 카테고리(Music, SFX, UI, Voice)별로 오디오 버스를 사용하지 않는 것
- 오디오 타이밍에 시그널(`finished`) 대신 `_process()`를 사용하는 것
