# Unity 6.3 — 오디오 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** Unity 6 오디오 믹서 개선 사항

---

## 개요

Unity 6.3 오디오 시스템:
- **AudioSource**: GameObject에서 사운드 재생
- **Audio Mixer**: 믹싱, 이펙트 처리, 다이나믹 믹싱
- **Spatial Audio**: 3D 위치 기반 사운드

---

## 기본 오디오 재생

### AudioSource 컴포넌트

```csharp
AudioSource audioSource = GetComponent<AudioSource>();

// ✅ 재생
audioSource.Play();

// ✅ 지연 재생
audioSource.PlayDelayed(0.5f); // 0.5초

// ✅ 원샷 재생(현재 재생 중인 사운드를 방해하지 않음)
audioSource.PlayOneShot(clip);

// ✅ 정지
audioSource.Stop();

// ✅ 일시정지/재개
audioSource.Pause();
audioSource.UnPause();
```

### 특정 위치에서 사운드 재생 (정적 메서드)

```csharp
// ✅ 빠른 3D 사운드 재생(재생이 끝나면 자동으로 파괴됨)
AudioSource.PlayClipAtPoint(clip, transform.position);

// ✅ 볼륨 지정
AudioSource.PlayClipAtPoint(clip, transform.position, 0.7f);
```

---

## 3D 공간 오디오

### AudioSource 3D 설정

```csharp
AudioSource source = GetComponent<AudioSource>();

// Spatial Blend: 0 = 2D, 1 = 3D
source.spatialBlend = 1.0f; // 완전한 3D

// 도플러 효과 (속도에 따른 피치 변화)
source.dopplerLevel = 1.0f;

// 거리 감쇠
source.minDistance = 1f;   // 이 거리 이내에서는 최대 볼륨
source.maxDistance = 50f;  // 이 거리를 넘어서면 들리지 않음
source.rolloffMode = AudioRolloffMode.Logarithmic; // 자연스러운 감쇠
```

### 볼륨 롤오프 커브
- **Logarithmic**: 자연스럽고 사실적(권장)
- **Linear**: 일정한 비율로 감소
- **Custom**: 직접 커브 정의

---

## Audio Mixer (고급 믹싱)

### Audio Mixer 설정

1. `Assets > Create > Audio Mixer`
2. 믹서 열기: `Window > Audio > Audio Mixer`
3. 그룹 생성: Master > SFX, Music, Dialogue

### AudioSource를 Mixer 그룹에 할당

```csharp
using UnityEngine.Audio;

public AudioMixerGroup sfxGroup;

void Start() {
    AudioSource source = GetComponent<AudioSource>();
    source.outputAudioMixerGroup = sfxGroup; // SFX 그룹으로 라우팅
}
```

### 코드로 믹서 제어

```csharp
using UnityEngine.Audio;

public AudioMixer audioMixer;

// ✅ 볼륨 설정(노출된 파라미터)
audioMixer.SetFloat("MusicVolume", -10f); // dB (-80 to 0)

// ✅ 볼륨 가져오기
audioMixer.GetFloat("MusicVolume", out float volume);

// 선형값(0-1)을 dB로 변환
float volumeDB = Mathf.Log10(volumeLinear) * 20f;
audioMixer.SetFloat("MusicVolume", volumeDB);
```

### Mixer 파라미터 노출
Audio Mixer 창에서:
1. 파라미터(예: Volume)를 우클릭
2. "Expose 'Volume' to script" 선택
3. "Exposed Parameters" 탭에서 이름 변경(예: "MusicVolume")

---

## 오디오 이펙트

### Mixer 그룹에 이펙트 추가

Audio Mixer에서:
- 그룹 선택(예: SFX)
- "Add Effect" 클릭
- 선택: Reverb, Echo, Low Pass, High Pass, Distortion 등

### 대사 재생 중 음악 덕킹 (사이드체인)

```csharp
// Audio Mixer에서 설정:
// 1. "Duck Volume" 스냅샷 생성
// 2. 해당 스냅샷에서 음악 볼륨을 낮춤
// 3. 대사가 재생될 때 스냅샷으로 전환

public AudioMixerSnapshot normalSnapshot;
public AudioMixerSnapshot duckedSnapshot;

public void PlayDialogue(AudioClip clip) {
    duckedSnapshot.TransitionTo(0.5f); // 0.5초 전환
    audioSource.PlayOneShot(clip);
    Invoke(nameof(RestoreMusic), clip.length);
}

void RestoreMusic() {
    normalSnapshot.TransitionTo(1.0f); // 1초 만에 원상 복귀
}
```

---

## 오디오 성능

### 오디오 로딩 최적화

```csharp
// Audio Import Settings (Inspector):
// - Load Type:
//   - Decompress On Load: 작은 클립(SFX), 메모리에 완전히 로드됨
//   - Compressed In Memory: 중간 크기 클립, 런타임에 압축 해제됨(권장)
//   - Streaming: 큰 클립(음악), 디스크에서 스트리밍됨

// Compression Format:
// - PCM: 비압축, 최고 품질, 최대 용량
// - ADPCM: 3.5배 압축, SFX에 적합(SFX에 권장)
// - Vorbis/MP3: 고압축, 음악에 적합(음악에 권장)
```

### 오디오 프리로드

```csharp
// 재생 전 오디오 클립을 미리 로드(끊김 방지)
audioSource.clip.LoadAudioData();

// 로드 여부 확인
if (audioSource.clip.loadState == AudioDataLoadState.Loaded) {
    audioSource.Play();
}
```

---

## 음악 시스템

### 트랙 간 크로스페이드

```csharp
public IEnumerator CrossfadeMusic(AudioSource from, AudioSource to, float duration) {
    float elapsed = 0f;
    to.Play();

    while (elapsed < duration) {
        elapsed += Time.deltaTime;
        float t = elapsed / duration;

        from.volume = Mathf.Lerp(1f, 0f, t);
        to.volume = Mathf.Lerp(0f, 1f, t);

        yield return null;
    }

    from.Stop();
}
```

### 끊김 없는 음악 루프

```csharp
// Audio Import Settings:
// - 끊김 없는 음악 루프를 위해 "Loop" 체크
audioSource.loop = true;
```

---

## 자주 쓰이는 패턴

### 랜덤 피치 변화 (반복감 방지)

```csharp
void PlaySoundWithVariation(AudioClip clip) {
    AudioSource source = GetComponent<AudioSource>();
    source.pitch = Random.Range(0.9f, 1.1f); // ±10% 피치 변화
    source.PlayOneShot(clip);
}
```

### 발소리 사운드 (배열에서 무작위 선택)

```csharp
public AudioClip[] footstepClips;

void PlayFootstep() {
    AudioClip clip = footstepClips[Random.Range(0, footstepClips.Length)];
    AudioSource.PlayClipAtPoint(clip, transform.position, 0.5f);
}
```

### 사운드 재생 여부 확인

```csharp
if (audioSource.isPlaying) {
    // 사운드가 현재 재생 중
}
```

---

## Audio Listener

### 단일 리스너 규칙
- 한 번에 오직 하나의 `AudioListener`만 활성화되어야 함
- 보통 Main Camera에 부착됨

```csharp
// 여분의 리스너 비활성화
AudioListener listener = GetComponent<AudioListener>();
listener.enabled = false;
```

---

## 디버깅

### Audio 창
- `Window > Audio > Audio Mixer`
- 레벨 시각화, 스냅샷 테스트

### Audio Settings
- `Edit > Project Settings > Audio`
- 전역 볼륨, DSP 버퍼 크기, 스피커 모드

---

## 출처
- https://docs.unity3d.com/6000.0/Documentation/Manual/Audio.html
- https://docs.unity3d.com/6000.0/Documentation/Manual/AudioMixer.html
