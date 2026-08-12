# Unity 6.3 — Addressables

**최종 확인일:** 2026-02-13
**상태:** 프로덕션 준비 완료
**패키지:** `com.unity.addressables` (Package Manager)

---

## 개요

**Addressables**는 Unity의 고급 에셋 관리 시스템으로, `Resources.Load()`를 대체하여
비동기 로딩, 원격 콘텐츠 배포, 향상된 메모리 제어를 제공한다.

**Addressables를 사용해야 하는 경우:**
- 비동기 에셋 로딩 (논블로킹)
- DLC 및 원격 콘텐츠
- 메모리 최적화 (필요 시 로드/언로드)
- 에셋 의존성 관리
- 에셋이 많은 대규모 프로젝트

**Addressables를 사용하지 말아야 하는 경우:**
- 소규모 프로젝트 (오버헤드가 그만한 가치가 없음)
- 시작 시점에 즉시 필요한 에셋 (직접 참조를 사용할 것)

---

## 설치

### Package Manager를 통한 설치

1. `Window > Package Manager`
2. Unity Registry > "Addressables" 검색
3. `Addressables` 설치

---

## 핵심 개념

### 1. **Addressable 에셋**
- "Addressable"로 표시된 에셋 (고유 키가 할당됨)
- 런타임에 키로 로드 가능

### 2. **에셋 그룹 (Asset Groups)**
- 에셋을 조직화 (예: "UI", "Weapons", "Level1")
- 그룹은 빌드 설정을 결정 (로컬 vs 원격)

### 3. **비동기 로딩**
- 모든 로딩은 비동기 (논블로킹)
- `AsyncOperationHandle`을 반환

### 4. **참조 카운팅**
- Addressables는 에셋 사용을 추적
- 사용이 끝나면 수동으로 에셋을 해제해야 함

---

## 설정

### 1. 에셋을 Addressable로 표시

1. Project 창에서 에셋 선택
2. Inspector > "Addressable" 체크
3. 키 할당 (예: "Enemies/Goblin")

**또는 스크립트로:**
```csharp
#if UNITY_EDITOR
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Settings;

AddressableAssetSettings.AddAssetEntry(guid, "MyAssetKey", "Default Local Group");
#endif
```

---

### 2. 그룹 생성

`Window > Asset Management > Addressables > Groups`

- **Default Local Group**: 빌드에 번들로 포함됨
- **Remote Group**: 서버(CDN)에 호스팅됨

---

## 기본 로딩

### 에셋 비동기 로드

```csharp
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class AssetLoader : MonoBehaviour {
    async void Start() {
        // ✅ 에셋을 비동기로 로드
        AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin");
        await handle.Task;

        if (handle.Status == AsyncOperationStatus.Succeeded) {
            GameObject prefab = handle.Result;
            Instantiate(prefab);
        } else {
            Debug.LogError("Failed to load asset");
        }

        // ⚠️ 중요: 사용이 끝나면 반드시 해제할 것
        Addressables.Release(handle);
    }
}
```

---

### 로드 후 즉시 인스턴스화

```csharp
async void SpawnEnemy() {
    // ✅ 한 단계로 로드 후 인스턴스화
    AsyncOperationHandle<GameObject> handle = Addressables.InstantiateAsync("Enemies/Goblin");
    await handle.Task;

    GameObject enemy = handle.Result;
    // enemy 사용...

    // ✅ 파괴할 때 해제
    Addressables.ReleaseInstance(enemy);
}
```

---

### 여러 에셋 로드

```csharp
async void LoadAllWeapons() {
    // "Weapons" 라벨이 붙은 모든 에셋을 로드
    AsyncOperationHandle<IList<GameObject>> handle = Addressables.LoadAssetsAsync<GameObject>("Weapons", null);
    await handle.Task;

    foreach (var weapon in handle.Result) {
        Debug.Log($"Loaded: {weapon.name}");
    }

    Addressables.Release(handle);
}
```

---

## 에셋 라벨 (태그)

### 라벨 지정

1. `Window > Asset Management > Addressables > Groups`
2. 에셋 선택 > Inspector > Labels > 라벨 추가 (예: "Level1", "UI")

### 라벨로 로드

```csharp
// "Level1" 라벨이 붙은 모든 에셋을 로드
Addressables.LoadAssetsAsync<GameObject>("Level1", null);
```

---

## 원격 콘텐츠 (DLC)

### 원격 그룹 설정

1. 새 그룹 생성: `Window > Addressables > Groups > Create New Group > Packed Assets`
2. 그룹 설정:
   - **Build Path**: `ServerData/[BuildTarget]`
   - **Load Path**: `http://yourcdn.com/content/[BuildTarget]`

### 원격 콘텐츠 빌드

1. `Window > Asset Management > Addressables > Build > New Build > Default Build Script`
2. `ServerData/` 폴더를 CDN에 업로드
3. 게임이 원격 서버에서 에셋을 로드함

---

## 프리로딩 / 캐싱

### 의존성 다운로드

```csharp
async void PreloadLevel() {
    // 메모리에 로드하지 않고 그룹 내 모든 에셋을 다운로드
    AsyncOperationHandle handle = Addressables.DownloadDependenciesAsync("Level1");
    await handle.Task;

    // 이제 "Level1" 에셋이 캐시되어 즉시 로드됨
    Addressables.Release(handle);
}
```

### 다운로드 크기 확인

```csharp
async void CheckDownloadSize() {
    AsyncOperationHandle<long> handle = Addressables.GetDownloadSizeAsync("Level1");
    await handle.Task;

    long sizeInBytes = handle.Result;
    Debug.Log($"Download size: {sizeInBytes / (1024 * 1024)} MB");

    Addressables.Release(handle);
}
```

---

## 메모리 관리

### 에셋 해제

```csharp
// ✅ 사용이 끝나면 항상 해제할 것
Addressables.Release(handle);

// ✅ 인스턴스화된 오브젝트의 경우
Addressables.ReleaseInstance(gameObject);
```

### 참조 카운트 확인

```csharp
// Addressables는 참조 카운팅을 사용함
// refCount == 0이 되면 에셋이 언로드됨
```

---

## 에셋 레퍼런스 (인스펙터에서 할당)

### AssetReference 사용

```csharp
using UnityEngine.AddressableAssets;

public class EnemySpawner : MonoBehaviour {
    // ✅ Inspector에서 할당 (드래그 & 드롭)
    public AssetReference enemyPrefab;

    async void SpawnEnemy() {
        AsyncOperationHandle<GameObject> handle = enemyPrefab.InstantiateAsync();
        await handle.Task;

        GameObject enemy = handle.Result;
        // enemy 사용...

        enemyPrefab.ReleaseInstance(enemy);
    }
}
```

---

## 씬 (Scenes)

### Addressable 씬 로드

```csharp
using UnityEngine.SceneManagement;

async void LoadScene() {
    AsyncOperationHandle<SceneInstance> handle = Addressables.LoadSceneAsync("MainMenu", LoadSceneMode.Additive);
    await handle.Task;

    SceneInstance sceneInstance = handle.Result;
    // 씬이 로드됨

    // 씬 언로드
    await Addressables.UnloadSceneAsync(handle).Task;
}
```

---

## 공통 패턴

### 지연 로딩 (필요 시 로드)

```csharp
Dictionary<string, AsyncOperationHandle<GameObject>> loadedAssets = new();

async Task<GameObject> GetAsset(string key) {
    if (!loadedAssets.ContainsKey(key)) {
        var handle = Addressables.LoadAssetAsync<GameObject>(key);
        await handle.Task;
        loadedAssets[key] = handle;
    }
    return loadedAssets[key].Result;
}
```

---

### 씬 언로드 시 정리

```csharp
void OnDestroy() {
    // 모든 핸들 해제
    foreach (var handle in loadedAssets.Values) {
        Addressables.Release(handle);
    }
    loadedAssets.Clear();
}
```

---

## 콘텐츠 카탈로그 업데이트 (라이브 업데이트)

### 카탈로그 업데이트 확인

```csharp
async void CheckForUpdates() {
    AsyncOperationHandle<List<string>> handle = Addressables.CheckForCatalogUpdates();
    await handle.Task;

    if (handle.Result.Count > 0) {
        Debug.Log("Updates available");
        await Addressables.UpdateCatalogs(handle.Result).Task;
    }

    Addressables.Release(handle);
}
```

---

## 성능 팁

- 자주 사용하는 에셋은 시작 시점에 **프리로드**할 것
- 필요 없어지면 즉시 에셋을 **해제**할 것
- 관련 에셋을 일괄 로드하려면 **라벨**을 사용할 것
- 오프라인 사용을 위해 원격 콘텐츠를 **캐시**할 것

---

## 디버깅

### Addressables Event Viewer

`Window > Asset Management > Addressables > Event Viewer`

- 모든 로드/해제 작업을 표시
- 에셋별 메모리 사용량
- 참조 카운트

### Addressables Profiler

`Window > Asset Management > Addressables > Profiler`

- 실시간 에셋 사용 현황
- 번들 로딩 통계

---

## Resources로부터의 마이그레이션

```csharp
// ❌ 이전 방식: Resources.Load (동기, 프레임을 블로킹)
GameObject prefab = Resources.Load<GameObject>("Enemies/Goblin");

// ✅ 새로운 방식: Addressables (비동기, 논블로킹)
var handle = await Addressables.LoadAssetAsync<GameObject>("Enemies/Goblin").Task;
GameObject prefab = handle.Result;
```

---

## 출처
- https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html
- https://learn.unity.com/tutorial/addressables
