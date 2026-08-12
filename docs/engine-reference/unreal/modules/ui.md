# Unreal Engine 5.7 — UI 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** UE 5.7 UMG 및 CommonUI 개선 사항

---

## 개요

UE 5.7 UI 시스템:
- **UMG(Unreal Motion Graphics)**: 위젯 기반 비주얼 UI(권장)
- **CommonUI**: 입력 방식을 인식하는 크로스플랫폼 UI 프레임워크(콘솔/PC)
- **Slate**: 저수준 C++ UI(엔진/에디터 UI)

---

## UMG(Unreal Motion Graphics)

### Widget Blueprint 생성

1. 콘텐츠 브라우저 > User Interface > Widget Blueprint
2. 위젯 디자이너 열기
3. Palette에서 위젯을 드래그: Button, Text, Image, ProgressBar 등

---

## C++에서 기본 UMG 설정

### 위젯 생성 및 표시

```cpp
#include "Blueprint/UserWidget.h"

UPROPERTY(EditAnywhere, Category = "UI")
TSubclassOf<UUserWidget> HealthBarWidgetClass;

void AMyCharacter::BeginPlay() {
    Super::BeginPlay();

    // 위젯 생성
    UUserWidget* HealthBarWidget = CreateWidget<UUserWidget>(GetWorld(), HealthBarWidgetClass);

    // 뷰포트에 추가
    HealthBarWidget->AddToViewport();
}
```

### 위젯 제거

```cpp
HealthBarWidget->RemoveFromParent();
```

---

## C++에서 위젯 요소 접근

### 위젯 요소에 바인딩

```cpp
UCLASS()
class UMyHealthWidget : public UUserWidget {
    GENERATED_BODY()

public:
    // ✅ 위젯 요소에 바인딩(Widget Blueprint 내 이름과 일치해야 함)
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UTextBlock> HealthText;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UProgressBar> HealthBar;

    void UpdateHealth(int32 CurrentHealth, int32 MaxHealth) {
        HealthText->SetText(FText::FromString(FString::Printf(TEXT("%d / %d"), CurrentHealth, MaxHealth)));
        HealthBar->SetPercent((float)CurrentHealth / MaxHealth);
    }
};
```

---

## 자주 쓰는 UMG 위젯

### Text Block

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UTextBlock> ScoreText;

ScoreText->SetText(FText::FromString(TEXT("Score: 100")));
ScoreText->SetColorAndOpacity(FLinearColor::Green);
```

### Button

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UButton> PlayButton;

void NativeConstruct() override {
    Super::NativeConstruct();

    // 버튼 클릭 바인딩
    PlayButton->OnClicked.AddDynamic(this, &UMyMenuWidget::OnPlayClicked);
}

UFUNCTION()
void OnPlayClicked() {
    UE_LOG(LogTemp, Warning, TEXT("Play clicked"));
}
```

### Image

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UImage> PlayerAvatar;

PlayerAvatar->SetBrushFromTexture(AvatarTexture);
PlayerAvatar->SetColorAndOpacity(FLinearColor::White);
```

### Progress Bar

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UProgressBar> HealthBar;

HealthBar->SetPercent(0.75f); // 75%
HealthBar->SetFillColorAndOpacity(FLinearColor::Red);
```

### Slider

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<USlider> VolumeSlider;

void NativeConstruct() override {
    Super::NativeConstruct();
    VolumeSlider->OnValueChanged.AddDynamic(this, &UMyWidget::OnVolumeChanged);
}

UFUNCTION()
void OnVolumeChanged(float Value) {
    // Value는 0.0 - 1.0 범위임
    UE_LOG(LogTemp, Warning, TEXT("Volume: %f"), Value);
}
```

### EditableTextBox(입력 필드)

```cpp
UPROPERTY(meta = (BindWidget))
TObjectPtr<UEditableTextBox> PlayerNameInput;

void NativeConstruct() override {
    Super::NativeConstruct();
    PlayerNameInput->OnTextChanged.AddDynamic(this, &UMyWidget::OnNameChanged);
}

UFUNCTION()
void OnNameChanged(const FText& Text) {
    FString PlayerName = Text.ToString();
}
```

---

## UMG 애니메이션

### 애니메이션 재생

```cpp
UPROPERTY(Transient, meta = (BindWidgetAnim))
TObjectPtr<UWidgetAnimation> FadeInAnimation;

void ShowUI() {
    PlayAnimation(FadeInAnimation);
}
```

### 애니메이션 정지

```cpp
StopAnimation(FadeInAnimation);
```

---

## Canvas Panel(레이아웃)

### Canvas Panel(절대 위치 지정)

```cpp
// Widget Blueprint에서 절대 위치 지정에 사용
// 반응형 UI를 위해 위젯을 모서리/가장자리에 앵커링
```

### Vertical Box(수직 스택)

```cpp
// 자식 위젯을 수직으로 자동 스택
```

### Horizontal Box(수평 스택)

```cpp
// 자식 위젯을 수평으로 자동 스택
```

### Grid Panel(그리드 레이아웃)

```cpp
// 자식 위젯을 그리드로 배치
```

---

## World Space UI(3D UI)

### Widget Component(월드 내 3D UI)

```cpp
#include "Components/WidgetComponent.h"

UWidgetComponent* HealthBarWidget = CreateDefaultSubobject<UWidgetComponent>(TEXT("HealthBar"));
HealthBarWidget->SetupAttachment(RootComponent);
HealthBarWidget->SetWidgetClass(HealthBarWidgetClass);
HealthBarWidget->SetWidgetSpace(EWidgetSpace::World); // 3D 월드 스페이스
HealthBarWidget->SetDrawSize(FVector2D(200, 50));
```

---

## UMG에서 입력 처리

### 키보드 입력 오버라이드

```cpp
UCLASS()
class UMyWidget : public UUserWidget {
    GENERATED_BODY()

public:
    virtual FReply NativeOnKeyDown(const FGeometry& InGeometry, const FKeyEvent& InKeyEvent) override {
        if (InKeyEvent.GetKey() == EKeys::Escape) {
            // Escape 키 처리
            CloseMenu();
            return FReply::Handled();
        }
        return Super::NativeOnKeyDown(InGeometry, InKeyEvent);
    }
};
```

---

## CommonUI(크로스플랫폼 입력)

### CommonUI 플러그인 활성화

```cpp
// 활성화: Edit > Plugins > CommonUI
// 에디터 재시작
```

### CommonUI 위젯 사용

```cpp
// CommonUI 위젯:
// - CommonActivatableWidget: 화면/메뉴의 기반이 되는 위젯
// - CommonButtonBase: 입력 방식을 인식하는 버튼(게임패드 + 마우스)
// - CommonTextBlock: 스타일이 적용된 텍스트
```

### CommonActivatableWidget 예시

```cpp
UCLASS()
class UMyMenuWidget : public UCommonActivatableWidget {
    GENERATED_BODY()

public:
    virtual void NativeOnActivated() override {
        Super::NativeOnActivated();
        // 메뉴가 활성화됨(표시됨)
    }

    virtual void NativeOnDeactivated() override {
        Super::NativeOnDeactivated();
        // 메뉴가 비활성화됨(숨겨짐)
    }
};
```

---

## HUD 클래스(UMG의 대안)

### HUD 생성

```cpp
UCLASS()
class AMyHUD : public AHUD {
    GENERATED_BODY()

public:
    virtual void DrawHUD() override {
        Super::DrawHUD();

        // 텍스트 그리기
        DrawText(TEXT("Score: 100"), FLinearColor::White, 50, 50);

        // 텍스처 그리기
        DrawTexture(CrosshairTexture, Canvas->SizeX / 2, Canvas->SizeY / 2, 32, 32);
    }
};
```

---

## 성능 팁

### UMG 최적화

```cpp
// Invalidation Box: 콘텐츠가 변경될 때만 다시 그림
// Widget Blueprint에 "Invalidation Box" 위젯을 추가

// 필요하지 않으면 틱(Tick) 비활성화
bIsFocusable = false;
SetVisibility(ESlateVisibility::Collapsed); // Collapsed = 렌더링되지 않음
```

---

## 디버깅

### UI 디버그 명령어

```cpp
// 콘솔 명령어:
// widget.debug - 위젯 계층 구조 표시
// Slate.ShowDebugOutlines 1 - 위젯 경계 표시
// stat slate - Slate 성능 표시
```

---

## 출처
- https://docs.unrealengine.com/5.7/en-US/umg-ui-designer-for-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/
