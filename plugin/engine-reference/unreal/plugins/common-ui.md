# Unreal Engine 5.7 — CommonUI 플러그인

**최종 확인일:** 2026-02-13
**상태:** 프로덕션 레디
**플러그인:** `CommonUI` (기본 내장, Plugins에서 활성화)

---

## 개요

**CommonUI**는 게임패드, 마우스, 터치의 입력 라우팅을 자동으로 처리하는 크로스 플랫폼
UI 프레임워크다. PC, 콘솔, 모바일 전반에서 플랫폼별 코드를 최소화하면서 원활하게
동작해야 하는 게임을 위해 설계되었다.

**CommonUI를 사용해야 하는 경우:**
- 멀티 플랫폼 게임(콘솔 + PC)
- 게임패드/마우스/터치 입력의 자동 라우팅
- 입력 방식에 구애받지 않는 UI(동일한 UI가 어떤 입력 방식에서도 동작)
- 위젯 포커스 및 내비게이션
- 액션 바 및 입력 힌트

**CommonUI를 사용하지 말아야 하는 경우:**
- 마우스 전용 UI만 필요한 PC 전용 게임(표준 UMG가 더 단순함)
- 내비게이션 요구사항이 없는 단순한 UI

---

## 표준 UMG와의 주요 차이점

| 기능 | 표준 UMG | CommonUI |
|---------|--------------|----------|
| **입력 처리** | 위젯별 수동 처리 | 자동 라우팅 |
| **포커스 관리** | 기본 수준 | 고급 내비게이션 |
| **플랫폼 전환** | 수동 감지 | 자동 |
| **입력 프롬프트** | 아이콘 하드코딩 | 플랫폼별 동적 표시 |
| **화면 스택** | 수동 | 내장 액티베이터블 위젯 |

---

## 설정

### 1. 플러그인 활성화

`Edit > Plugins > CommonUI > Enabled > Restart`

### 2. 프로젝트 설정 구성

`Project Settings > Plugins > CommonUI`:
- **Default Input Type**: Gamepad(또는 자동 감지)
- **Platform-Specific Settings**: 플랫폼별 입력 아이콘 구성

### 3. Common Input Settings 애셋 생성

1. Content Browser > Input > Common Input Settings
2. 플랫폼별 입력 데이터 구성:
   - Default Gamepad Data
   - Default Mouse & Keyboard Data
   - Default Touch Data

---

## 핵심 위젯

### CommonActivatableWidget(화면 관리)

활성화/비활성화가 가능한 화면/메뉴를 위한 기반 클래스.

```cpp
#include "CommonActivatableWidget.h"

UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();
        // Menu is now visible and focused
        UE_LOG(LogTemp, Warning, TEXT("Menu activated"));
    }

    virtual void NativeOnDeactivated() override {
        Super::NativeOnDeactivated();
        // Menu is now hidden
        UE_LOG(LogTemp, Warning, TEXT("Menu deactivated"));
    }

    virtual UWidget* NativeGetDesiredFocusTarget() const override {
        // Return widget that should receive focus (e.g., first button)
        return PlayButton;
    }

private:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;
};
```

---

### CommonButtonBase(입력 인지 버튼)

표준 UMG Button을 대체한다. 게임패드/마우스/키보드 입력을 자동으로 처리한다.

```cpp
#include "CommonButtonBase.h"

UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;

    virtual void NativeConstruct() override {
        Super::NativeConstruct();

        // Bind button click (works with any input method)
        PlayButton->OnClicked().AddUObject(this, &UMyMenuWidget::OnPlayClicked);

        // Set button text
        PlayButton->SetButtonText(FText::FromString(TEXT("Play")));
    }

    void OnPlayClicked() {
        UE_LOG(LogTemp, Warning, TEXT("Play clicked"));
    }
};
```

---

### CommonTextBlock(스타일이 적용된 텍스트)

CommonUI 스타일링을 지원하는 텍스트 위젯.

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonTextBlock> TitleText;

TitleText->SetText(FText::FromString(TEXT("Main Menu")));
```

---

### CommonActionWidget(입력 프롬프트)

입력 프롬프트를 표시한다(예: "Press A to Continue", 올바른 버튼 아이콘을 자동으로 표시).

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActionWidget> ConfirmActionWidget;

// Bind to input action
ConfirmActionWidget->SetInputAction(ConfirmInputActionData);
// Automatically shows correct icon (A on Xbox, X on PlayStation, Enter on PC)
```

---

## 위젯 스택(화면 관리)

### CommonActivatableWidgetStack

화면 스택을 관리한다(예: Main Menu → Settings → Controls).

```cpp
#include "Widgets/CommonActivatableWidgetContainer.h"

UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActivatableWidgetStack> WidgetStack;

// Push new screen onto stack
void ShowSettingsMenu() {
    WidgetStack->AddWidget(USettingsMenuWidget::StaticClass());
}

// Pop current screen (go back)
void GoBack() {
    WidgetStack->DeactivateWidget();
}
```

---

## 입력 액션(CommonUI 방식)

### 입력 액션 정의

**Common Input Action Data Table**을 생성한다:
1. Content Browser > Miscellaneous > Data Table
2. Row Structure: `CommonInputActionDataBase`
3. 액션(Confirm, Cancel, Navigate 등)에 대한 행을 추가

예시 행:
- **Action Name**: Confirm
- **Default Input**: Gamepad Face Button Bottom(A/Cross)
- **Alternate Inputs**: Enter(키보드), 마우스 왼쪽 버튼

---

### 위젯에서 입력 액션 바인딩

```cpp
#include "Input/CommonUIActionRouterBase.h"

UCLASS()
class UMyWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();

        // Bind input action
        FBindUIActionArgs BindArgs(ConfirmInputAction, FSimpleDelegate::CreateUObject(this, &UMyWidget::OnConfirm));
        BindArgs.bDisplayInActionBar = true; // Show in action bar
        RegisterUIActionBinding(BindArgs);
    }

    void OnConfirm() {
        UE_LOG(LogTemp, Warning, TEXT("Confirmed"));
    }

private:
    UPROPERTY(EditDefaultsOnly, Category = "Input")
    FDataTableRowHandle ConfirmInputAction;
};
```

---

## 포커스 및 내비게이션

### 자동 게임패드 내비게이션

CommonUI는 게임패드 내비게이션(D-Pad/스틱으로 버튼 간 이동)을 자동으로 처리한다.

```cpp
// In Widget Blueprint:
// - Widgets are automatically navigable if they inherit from CommonButton/CommonUserWidget
// - Focus order is determined by widget hierarchy and layout
```

### 커스텀 포커스 내비게이션

```cpp
// Override focus navigation
virtual UWidget* NativeGetDesiredFocusTarget() const override {
    return FirstButton; // Return widget that should receive focus
}
```

---

## 입력 모드(게임 vs UI)

### 입력 모드 전환

```cpp
#include "CommonUIExtensions.h"

// Switch to UI-only mode (pause game, show cursor)
UCommonUIExtensions::PushStreamedGameplayUIInputConfig(this, FrontendInputConfig);

// Return to game mode (hide cursor, resume gameplay)
UCommonUIExtensions::PopInputConfig(this);
```

---

## 플랫폼별 입력 아이콘

### 입력 아이콘 구성

1. 플랫폼별로 **Common Input Base Controller Data** 애셋을 생성:
   - 게임패드(Xbox, PlayStation, Switch)
   - 마우스 & 키보드
   - 터치

2. 플랫폼별 아이콘 할당:
   - Gamepad Face Button Bottom: `A`(Xbox), `Cross`(PlayStation)
   - Confirm Key: `Enter` 아이콘

3. **Common Input Settings** 애셋에 할당

### 올바른 아이콘 자동 표시

```cpp
// CommonActionWidget automatically shows correct icon for current platform
UPROPERTY(meta = (BindWidget))
TObjectPtr<UCommonActionWidget> JumpActionWidget;

JumpActionWidget->SetInputAction(JumpInputActionData);
// Shows "A" on Xbox, "Cross" on PlayStation, "Space" on PC
```

---

## 일반적인 패턴

### 내비게이션이 있는 메인 메뉴

```cpp
UCLASS()
class UMainMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> PlayButton;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> SettingsButton;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UCommonButtonBase> QuitButton;

    virtual void NativeConstruct() override {
        Super::NativeConstruct();

        PlayButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnPlayClicked);
        SettingsButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnSettingsClicked);
        QuitButton->OnClicked().AddUObject(this, &UMainMenuWidget::OnQuitClicked);
    }

    virtual UWidget* NativeGetDesiredFocusTarget() const override {
        return PlayButton; // Focus "Play" button when menu opens
    }

    void OnPlayClicked() { /* Start game */ }
    void OnSettingsClicked() { /* Open settings */ }
    void OnQuitClicked() { /* Quit game */ }
};
```

---

### Back 액션이 있는 일시정지 메뉴

```cpp
UCLASS()
class UPauseMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

protected:
    UPROPERTY(EditDefaultsOnly, Category = "Input")
    FDataTableRowHandle BackInputAction; // Assign "Cancel" action in Blueprint

    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();

        // Bind "Back" input (B/Circle/Escape)
        FBindUIActionArgs BindArgs(BackInputAction, FSimpleDelegate::CreateUObject(this, &UPauseMenuWidget::OnBack));
        RegisterUIActionBinding(BindArgs);
    }

    void OnBack() {
        DeactivateWidget(); // Close pause menu
    }
};
```

---

## 성능 팁

- 화면 관리에는 **CommonActivatableWidgetStack**을 사용한다(활성화/비활성화를 자동 처리)
- 매 프레임 위젯을 생성/파괴하지 않는다(위젯을 재사용)
- 복잡한 메뉴에는 **Lazy Widgets**를 사용한다(필요할 때만 생성)

---

## 디버깅

### CommonUI 디버그 명령

```cpp
// Console commands:
// CommonUI.DumpActivatableTree - Show active widget hierarchy
// CommonUI.DumpActionBindings - Show registered input actions
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/commonui-quickstart-guide-for-unreal-engine/
