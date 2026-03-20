- [2D 贴图属性](#2d-贴图属性)
  - [\_ST](#_st)
- [Range 范围滑块属性](#range-范围滑块属性)
- [标记](#标记)


用于定义材质属性，这些属性可以在 Unity 编辑器中通过材质面板进行调整，从而影响 Shader 的行为和外观。

直接来看一个例子 2D 贴图属性

### 2D 贴图属性

_MainTex 指定要在 Shader 中使用的纹理（unity 会默认使用MainTex作为主纹理）

```HLSL
_MainTex("Sprite Texture", 2D) = "white" {}
```  

- "Sprite Texture" ：属性的显示名称
- 2D ：指定属性的类型为 2D 纹理
- = "white" ：设置属性的默认值为白色纹理  

在 Shader 代码中，你可以通过 sampler2D _MainTex 来声明一个采样器，并使用 tex2D(_MainTex, uv) 来获取纹理颜色

#### _ST

对于每一个贴图，Unity 会按命名规则自动提供/绑定参数，你可以直接在 Pass 中声明

```HLSL
float XXXX_ST;
// _MainTex_ST.xy  // Tiling
// _MainTex_ST.zw  // Offset
o.uv = TRANSFORM_TEX(v.uv, _MainTex);
o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw
```
TRANSFORM_TEX 是 unity 的一个宏，它相当于下面的那个，总之你有贴图之后，可以直接声明 _ST 后缀，来使用贴图的 Tiling 和 Offset

### Range 范围滑块属性

Range(0, 1) 滑块

### 标记

- [PerRendererData]   
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
