# Unity 6.3 — UI 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** Unity 6의 UI Toolkit은 런타임 UI에서 프로덕션 준비가 완료됨

---

## 개요

Unity 6 UI 시스템:
- **UI Toolkit** (권장): 최신, 고성능, HTML/CSS와 유사한 방식 (Unity 6에서 프로덕션 준비 완료)
- **UGUI (Canvas)**: 레거시 시스템, 여전히 지원되지만 신규 프로젝트에는 권장하지 않음
- **IMGUI**: 에디터 전용, 런타임 UI에는 deprecated

---

## UI Toolkit (모던 UI)

### UI Document 설정

1. UXML 생성 (UI 구조):
   - `Assets > Create > UI Toolkit > UI Document`
2. USS 생성 (스타일링):
   - `Assets > Create > UI Toolkit > StyleSheet`
3. 씬에 추가:
   - `GameObject > UI Toolkit > UI Document`
   - UXML을 `UIDocument > Source Asset`에 할당

---

### UXML (UI 구조)

```xml
<!-- MainMenu.uxml -->
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <ui:VisualElement class="container">
        <ui:Label text="Main Menu" class="title" />
        <ui:Button name="play-button" text="Play" />
        <ui:Button name="settings-button" text="Settings" />
        <ui:Button name="quit-button" text="Quit" />
    </ui:VisualElement>
</ui:UXML>
```

---

### USS (스타일링)

```css
/* MainMenu.uss */
.container {
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    background-color: rgb(30, 30, 30);
}

.title {
    font-size: 48px;
    color: white;
    margin-bottom: 20px;
}

Button {
    width: 200px;
    height: 50px;
    margin: 10px;
    font-size: 24px;
}

Button:hover {
    background-color: rgb(100, 150, 200);
}
```

---

### C# 스크립팅 (UI Toolkit)

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour {
    void OnEnable() {
        var root = GetComponent<UIDocument>().rootVisualElement;

        // Query elements by name
        var playButton = root.Q<Button>("play-button");
        var settingsButton = root.Q<Button>("settings-button");
        var quitButton = root.Q<Button>("quit-button");

        // Register callbacks
        playButton.clicked += OnPlayClicked;
        settingsButton.clicked += OnSettingsClicked;
        quitButton.clicked += Application.Quit;
    }

    void OnPlayClicked() {
        Debug.Log("Play clicked");
        // Load game scene
    }

    void OnSettingsClicked() {
        Debug.Log("Settings clicked");
        // Open settings menu
    }
}
```

---

### 자주 쓰이는 UI 요소

```csharp
// Label (text display)
var label = root.Q<Label>("score-label");
label.text = "Score: 100";

// Button
var button = root.Q<Button>("submit-button");
button.clicked += OnSubmit;

// TextField (text input)
var textField = root.Q<TextField>("name-input");
string playerName = textField.value;

// Toggle (checkbox)
var toggle = root.Q<Toggle>("music-toggle");
bool isMusicEnabled = toggle.value;

// Slider
var slider = root.Q<Slider>("volume-slider");
float volume = slider.value; // 0-1

// DropdownField (dropdown menu)
var dropdown = root.Q<DropdownField>("difficulty-dropdown");
dropdown.choices = new List<string> { "Easy", "Normal", "Hard" };
dropdown.value = "Normal";
```

---

### 동적 UI 생성 (UXML 없이)

```csharp
void CreateUI() {
    var root = GetComponent<UIDocument>().rootVisualElement;

    // Create elements
    var container = new VisualElement();
    container.AddToClassList("container");

    var label = new Label("Hello, UI Toolkit!");
    var button = new Button(() => Debug.Log("Clicked")) { text = "Click Me" };

    container.Add(label);
    container.Add(button);
    root.Add(container);
}
```

---

### USS Flexbox 레이아웃

```css
/* Horizontal layout */
.horizontal {
    flex-direction: row;
}

/* Vertical layout (default) */
.vertical {
    flex-direction: column;
}

/* Center children */
.centered {
    align-items: center;
    justify-content: center;
}

/* Spacing */
.spaced {
    justify-content: space-between;
}
```

---

## UGUI (레거시 Canvas UI)

### 기본 설정 (Unity 6에서도 여전히 동작)

```csharp
// GameObject > UI > Canvas (creates Canvas, EventSystem)

// UI Elements:
// - Text (use TextMeshPro instead)
// - Button
// - Image
// - Slider
// - Toggle
// - InputField
```

---

### UGUI 스크립팅

```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro; // TextMeshPro

public class LegacyUI : MonoBehaviour {
    public TextMeshProUGUI scoreText;
    public Button playButton;
    public Slider volumeSlider;

    void Start() {
        // Update text
        scoreText.text = "Score: 100";

        // Button click
        playButton.onClick.AddListener(OnPlayClicked);

        // Slider value changed
        volumeSlider.onValueChanged.AddListener(OnVolumeChanged);
    }

    void OnPlayClicked() {
        Debug.Log("Play clicked");
    }

    void OnVolumeChanged(float value) {
        AudioListener.volume = value;
    }
}
```

---

### TextMeshPro (더 나은 텍스트 렌더링)

```csharp
// Install: Window > TextMeshPro > Import TMP Essential Resources

// Use TMP_Text instead of Unity's Text component
using TMPro;

public TextMeshProUGUI tmpText;
tmpText.text = "High Quality Text";
tmpText.fontSize = 24;
tmpText.color = Color.white;
```

---

## Canvas 설정 (UGUI)

### 렌더 모드

```csharp
// Screen Space - Overlay: UI rendered on top of everything (no camera needed)
// Screen Space - Camera: UI rendered by specific camera (allows effects)
// World Space: UI in 3D world (e.g., floating health bars)
```

### Canvas Scaler (반응형 UI)

```csharp
// UI Scale Mode:
// - Constant Pixel Size: UI elements have fixed pixel size
// - Scale With Screen Size: UI scales based on reference resolution (RECOMMENDED)
// - Constant Physical Size: UI elements have fixed physical size (cm)

// Example: Scale With Screen Size
// Reference Resolution: 1920x1080
// Screen Match Mode: Match Width Or Height (0.5 = balanced)
```

---

## 레이아웃 그룹 (UGUI)

### Horizontal Layout Group

```csharp
// Auto-arranges children horizontally
// Add: GameObject > Add Component > Horizontal Layout Group
```

### Vertical Layout Group

```csharp
// Auto-arranges children vertically
```

### Grid Layout Group

```csharp
// Arranges children in a grid
```

---

## 성능 (UI Toolkit vs UGUI)

### UI Toolkit의 장점
- ✅ 더 빠른 렌더링 (retained mode)
- ✅ 요소가 많은 복잡한 UI에 더 적합
- ✅ 더 쉬운 스타일링 (CSS와 유사)
- ✅ 동적 UI에 더 적합

### UGUI의 장점
- ✅ 더 성숙하고 문서화가 풍부함
- ✅ Unity 에디터와의 통합이 더 우수함
- ✅ 초보자에게 더 쉬움

---

## 자주 쓰이는 패턴

### 체력바 (UI Toolkit)

```csharp
var healthBar = root.Q<VisualElement>("health-bar");
healthBar.style.width = new StyleLength(new Length(healthPercent, LengthUnit.Percent));
```

### 체력바 (UGUI)

```csharp
public Image healthBarImage;

void UpdateHealth(float percent) {
    healthBarImage.fillAmount = percent; // 0-1
}
```

---

### 페이드 인/아웃 (UI Toolkit)

```csharp
IEnumerator FadeIn(VisualElement element, float duration) {
    float elapsed = 0f;
    while (elapsed < duration) {
        elapsed += Time.deltaTime;
        element.style.opacity = Mathf.Lerp(0f, 1f, elapsed / duration);
        yield return null;
    }
}
```

---

## 디버깅

### UI Toolkit Debugger
- `Window > UI Toolkit > Debugger`
- 요소 계층, 스타일, 레이아웃을 검사

### UGUI Event System Debugger
- Hierarchy에서 EventSystem 선택
- Inspector에 활성 입력 모듈, 레이캐스트 정보 표시

---

## 출처
- https://docs.unity3d.com/6000.0/Documentation/Manual/UIElements.html
- https://docs.unity3d.com/Packages/com.unity.ui@2.0/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.ugui@2.0/manual/index.html
