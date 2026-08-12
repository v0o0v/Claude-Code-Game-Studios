# Unity 6.3 — 렌더링 모듈 레퍼런스

**최종 확인일:** 2026-02-13
**지식 공백:** LLM은 Unity 2022 LTS로 학습되었으며, Unity 6에는 대규모 렌더링 변경 사항이 있음

---

## 개요

Unity 6.3 LTS는 최신 렌더링 아키텍처로 **Scriptable Render Pipeline(SRP)**을 사용합니다:
- **URP (Universal Render Pipeline)**: 크로스 플랫폼, 모바일 친화적 (권장)
- **HDRP (High Definition Render Pipeline)**: 고사양 PC/콘솔용, 포토리얼리스틱
- **Built-in Pipeline**: Deprecated, 신규 프로젝트에는 사용하지 말 것

---

## 2022 LTS 대비 주요 변경 사항

### RenderGraph API (Unity 6+)
커스텀 렌더 패스는 이제 CommandBuffer 대신 RenderGraph를 사용합니다:

```csharp
// ✅ Unity 6+ (RenderGraph)
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData) {
    using var builder = renderGraph.AddRasterRenderPass<PassData>("MyPass", out var passData);
    builder.SetRenderFunc((PassData data, RasterGraphContext ctx) => {
        // Rendering commands
    });
}

// ❌ Old (CommandBuffer - still works but deprecated)
public override void Execute(ScriptableRenderContext context, ref RenderingData data) { }
```

### GPU Resident Drawer (Unity 6+)
대규모 드로우 콜 절감을 위한 자동 배칭:

```csharp
// Enable in URP Asset settings:
// Rendering > GPU Resident Drawer = Enabled
// Automatically batches thousands of objects with minimal CPU overhead
```

---

## URP 빠른 참조

### URP Asset 생성
1. `Assets > Create > Rendering > URP Asset (with Universal Renderer)`
2. `Project Settings > Graphics > Scriptable Render Pipeline Settings`에 할당

### URP Renderer Features
커스텀 렌더 패스 추가:

```csharp
using UnityEngine.Rendering.Universal;

public class OutlineRendererFeature : ScriptableRendererFeature {
    OutlineRenderPass pass;

    public override void Create() {
        pass = new OutlineRenderPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData data) {
        renderer.EnqueuePass(pass);
    }
}
```

---

## 머티리얼 & 셰이더

### Shader Graph (비주얼 셰이더 에디터)
Unity 6의 Shader Graph는 모든 셰이더 타입에 대해 프로덕션 준비가 완료되었습니다:

```csharp
// Create: Assets > Create > Shader Graph > URP > Lit Shader Graph
// No code needed, visual node-based editing
```

### HLSL 커스텀 셰이더 (URP)

```hlsl
// URP Lit shader template
Shader "Custom/URPLit" {
    Properties {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input) {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 frag(Varyings input) : SV_Target {
                return half4(1, 0, 0, 1); // Red
            }
            ENDHLSL
        }
    }
}
```

---

## 라이팅

### 베이크드 라이팅 (Unity 6 Progressive Lightmapper)

```csharp
// Mark objects as static: Inspector > Static > Contribute GI
// Bake: Window > Rendering > Lighting > Generate Lighting
```

### 실시간 라이트 (URP)

```csharp
// Main Light (Directional): Auto-handled by URP
// Additional Lights: Limited by "Additional Lights" setting in URP Asset

// Check light count in shader:
int lightCount = GetAdditionalLightsCount();
```

---

## 포스트 프로세싱

### Volume 시스템 (Unity 6+)

```csharp
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

// Add Volume component to GameObject
// Add Volume Profile asset
// Configure effects: Bloom, Color Grading, Depth of Field, etc.

// Script access:
Volume volume = GetComponent<Volume>();
if (volume.profile.TryGet<Bloom>(out var bloom)) {
    bloom.intensity.value = 2.5f;
}
```

---

## 성능

### SRP Batcher (자동 배칭)

```csharp
// Enable: URP Asset > Advanced > SRP Batcher = Enabled
// Batches draws with same shader variant (minimal CPU overhead)
```

### GPU 인스턴싱

```csharp
// Material: Enable "Enable GPU Instancing" checkbox
// Batches identical meshes (same material + mesh)

Graphics.RenderMeshInstanced(
    new RenderParams(material),
    mesh,
    0,
    matrices // NativeArray<Matrix4x4>
);
```

### 오클루전 컬링

```csharp
// Window > Rendering > Occlusion Culling
// Bake occlusion data for static geometry
```

---

## 자주 쓰이는 패턴

### 커스텀 카메라 렌더링

```csharp
// Get URP camera data
var cameraData = frameData.Get<UniversalCameraData>();
var camera = cameraData.camera;

// Access render targets
var colorTarget = cameraData.renderer.cameraColorTargetHandle;
```

### 스크린 스페이스 이펙트

```csharp
// Create ScriptableRendererFeature
// Inject pass at specific point: AfterRenderingOpaques, AfterRenderingTransparents, etc.
```

---

## 디버깅

### Frame Debugger
- `Window > Analysis > Frame Debugger`
- 드로우 콜을 단계별로 확인하고 상태를 검사

### Rendering Debugger (Unity 6+)
- `Window > Analysis > Rendering Debugger`
- URP 설정, 오버드로우, 라이팅을 실시간으로 확인

---

## 출처
- https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/index.html
- https://docs.unity3d.com/6000.0/Documentation/Manual/render-pipelines.html
