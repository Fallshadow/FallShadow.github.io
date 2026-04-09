定义具体的渲染过程。一个 Shader 可以包含多个 SubShader，以便在不同的硬件或渲染条件下使用不同的渲染路径。

包含 Tags 块，Pass 块和渲染状态设置。

渲染状态设置放在这里对其中的所有 pass 生效，当然这个也可以放到 pass 里，只对这个 pass 生效。

# CGINCLUDE ENDCG

位于 SubShader 中，因为有多可能有 pass，这条语句可以声明全局 pass 都公用的内容

```HLSL
CGINCLUDE
#pragma target 3.0
#include "UnityCG.cginc"
ENDCG
```

