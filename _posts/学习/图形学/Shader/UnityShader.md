## 语言

### CG

C for Graphics

由 NVIDIA 开发，旨在为开发者提供一种跨平台的着色器编程语言，能够在不同的图形 API（如 OpenGL 和 Direct3D）上运行。语法类似于 C 语言，易于学习和使用。提供了跨平台的能力，尽管在实际使用中，平台兼容性可能会受到限制。由于 NVIDIA 的支持，Cg 在其发布初期得到了广泛的使用，但随着时间的推移，其使用逐渐减少。

### HLSL

High-Level Shading Language

由微软开发，专为 Direct3D API 设计，提供了一种编写 GPU 着色器的高级语言。语法与 Cg 非常相似，主要区别在于一些特定的函数和语义。深度集成到 DirectX 中，成为 Windows 平台上开发者的首选。随着 DirectX 的发展，HLSL 不断更新，支持更高级的图形功能。

### ShaderLab

Unity 支持使用 Cg 和 HLSL 编写着色器，实际上，Unity 的 ShaderLab 允许开发者使用一种称为 "Cg/HLSL" 的混合模式，这使得开发者可以在 Unity 中编写兼容的着色器代码，而不必过于担心底层的 API 差异。

## 渲染队列

Background (1000) ：用于背景对象，最先渲染。天空盒、背景图像等。

Geometry (2000) ：默认队列，用于不透明对象。大多数不透明的几何体，如地形、建筑物、角色等

AlphaTest (2450) ：用于透明度测试对象（即使用 Alpha Test 的对象）。树叶、栅栏等需要透明度裁剪的对象。

Transparent (3000)：用于半透明对象，按深度排序后渲染。玻璃、烟雾、水面等需要半透明效果的对象。

Overlay (4000)：用于覆盖对象，最后渲染。GUI 元素、HUD、屏幕特效等。

游戏工程中自定义的渲染队列把控列表

## Shader 结构块

一般有 Properties 块，SubShader 块，Pass 块，CGPROGRAM/ENDCG 块，Tags 块，Fallback 块，CustomEditor 块

### Properties

用于定义材质属性，这些属性可以在 Unity 编辑器中通过材质面板进行调整，从而影响 Shader 的行为和外观。

#### 标记

- [PerRenderData]   
    这个标记告诉 Unity，这个属性的数据可以在每个渲染器实例中单独设置，而不是通过材质面板设置。这样更灵活，允许在不创建多个材质实例的情况下为不同的对象设置不同的属性值。  

    当一个属性被标记为 [PerRendererData] 时，它不会在材质的 Inspector 面板中显示。这是因为这个属性的值通常是通过脚本在运行时设置的，而不是通过材质面板。
    ```Cpp
    // 通过材质属性块来设置 [PerRendererData] 属性
    using UnityEngine;  

    public class SetPerRendererData : MonoBehaviour  
    {  
        public Texture2D customTexture;  

        void Start()  
        {  
            Renderer renderer = GetComponent<Renderer>();  
            MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();  

            // 设置自定义纹理  
            propertyBlock.SetTexture("_MainTex", customTexture);  

            // 应用材质属性块到渲染器  
            renderer.SetPropertyBlock(propertyBlock);  
        }  
    }  
    ```
- [Toggle(SomeKeyword)]  
    ```Cpp
    [Toggle(SomeKeyword)] _PropertyName("Display Name", Float) = 0  
    ```  
    用于在材质的 Inspector 面板中创建一个布尔类型的开关（复选框）。这个开关可以用于启用或禁用 Shader 中的某些功能或效果。    

    SomeKeyword : 这是一个预处理器符号或关键字。当复选框被选中时，这个关键字会被定义，Shader 可以根据这个关键字来决定是否执行某些代码块。

    Float : 指定属性的类型为浮点数。尽管在 Inspector 中显示为复选框，但在 Shader 中它实际上是一个浮点数（0 或 1）


#### 属性

- _MainTex  
指定要在 Shader 中使用的纹理。  
    ```Cpp
    _MainTex("Sprite Texture", 2D) = "white" {}
    ```  
    "Sprite Texture" ：属性的显示名称  

    2D ：指定属性的类型为 2D 纹理  

    = "white" ：设置属性的默认值为白色纹理  

    在 Shader 代码中，你可以通过 sampler2D _MainTex; 来声明一个采样器，并使用 tex2D(_MainTex, uv) 来获取纹理颜色

#### 属性参数

- Range  
    Range(0, 1) 滑块

### SubShader

定义具体的渲染过程。一个 Shader 可以包含多个 SubShader，以便在不同的硬件或渲染条件下使用不同的渲染路径。

包含 Tags 块，Pass 块和渲染状态设置。

#### Tags

```Cpp
Tags { "TagName" = "Value" }  
```

用于定义 Shader 的元数据，影响渲染顺序、渲染类型以及其他渲染行为。

- Queue

    指定渲染队列，决定对象的渲染顺序

        "Background": 在所有几何体之前渲染。

        "Geometry": 默认值，用于不透明对象。

        "AlphaTest": 用于透明度测试对象。

        "Transparent": 用于半透明对象，按深度排序。

        "Overlay": 在所有几何体之后渲染。

- RenderType

    指定渲染类型，用于后处理效果和其他渲染管线的优化

        "Opaque": 不透明对象。

        "Transparent": 半透明对象。

        "TransparentCutout": 透明度裁剪对象。

        "Background": 背景对象。

        "Overlay": 覆盖对象。

- IgnoreProjector

    指定对象是否忽略投影器，防止投影器（如阴影投影器）影响某些对象。
    ```Cpp
    Tags { "IgnoreProjector" = "True" }
    ```

- DisableBatching

    控制对象是否参与批处理。优化渲染性能，特别是在使用动态效果时

    常用值: "True", "False", "LODFading"

- ForceNoShadowCasting

    强制对象不投射阴影。用于特殊效果或优化

- PreviewType

    控制材质在材质编辑器中的预览方式（以平面、天空球、三维网格展示）

    常用值: "Plane", "Skybox", "Mesh"

- CanUseSpriteAtlas

    指示 Shader 是否可以与精灵图集一起使用，通常用于 2D 渲染优化

- LightMode

    指定 Shader 的光照模式，如 ForwardBase、ForwardAdd、Deferred 等

#### 渲染状态设置

- Cull Off

    关闭背面剔除。渲染对象的所有面（正面和背面）。通常用于需要双面渲染的对象，如透明物体或纸张效果。Unity 默认剔除背面（Cull Back），以提高渲染性能。

- Lighting Off

    关闭光照计算。忽略光照影响，通常用于不需要光照的效果，如 GUI 元素、特效或全屏着色器。关闭光照后，材质将不受场景光源的影响，通常只显示材质的基本颜色或纹理。

- ZWrite Off

    关闭深度写入。不将对象的深度信息写入深度缓冲区。常用于半透明对象，以避免深度冲突。关闭深度写入后，后续渲染的对象不会被当前对象的深度信息遮挡。

- ZTest [unity_GUIZTestMode]

    设置深度测试模式。[unity_GUIZTestMode] 是一个占位符，通常在 Unity 的内置 GUI 系统中使用，以根据需要动态设置深度测试模式。常见的深度测试模式包括 Less、Greater、LEqual、GEqual、Equal、NotEqual、Always 和 Never。如果你想手动设置，可以使用 ZTest LEqual 来表示仅当片段深度小于或等于当前深度缓冲区值时才通过测试。

        Less: 仅当片段深度小于当前深度缓冲区值时，片段才会被绘制。
        Greater: 仅当片段深度大于当前深度缓冲区值时，片段才会被绘制。
        LEqual: 仅当片段深度小于或等于当前深度缓冲区值时，片段才会被绘制。
        GEqual: 仅当片段深度大于或等于当前深度缓冲区值时，片段才会被绘制。
        Equal: 仅当片段深度等于当前深度缓冲区值时，片段才会被绘制。
        NotEqual: 仅当片段深度不等于当前深度缓冲区值时，片段才会被绘制。
        Always: 总是绘制片段，不进行深度测试。
        Never: 从不绘制片段。

- Blend SrcAlpha OneMinusSrcAlpha

    设置混合模式。这是一个常见的 Alpha 混合模式，用于处理透明度。SrcAlpha 表示源颜色的 alpha 值，而 OneMinusSrcAlpha 表示目标颜色的反向 alpha 值。这种混合模式会根据源颜色的 alpha 值来混合源和目标颜色，通常用于半透明效果。

#### Pass

- Name "Default"

    为这个渲染通道命名为 "Default"。命名可以帮助开发者识别和管理多个渲染通道。

- CGPROGRAM

    开始一个 Cg/HLSL 程序块。Cg 是一种由 NVIDIA 开发的着色器语言，Unity 支持使用 Cg 或 HLSL 编写着色器。

- #pragma vertex vert

    指定顶点着色器的入口函数为 vert。顶点着色器负责处理每个顶点的数据。

- #pragma fragment frag

    指定片段着色器的入口函数为 frag。片段着色器负责处理每个像素的数据。

- #pragma target 2.0

    指定着色器的目标编译级别为 2.0。这决定了着色器可以使用的功能集和硬件兼容性。较高的版本支持更多的功能，但要求更高的硬件支持。