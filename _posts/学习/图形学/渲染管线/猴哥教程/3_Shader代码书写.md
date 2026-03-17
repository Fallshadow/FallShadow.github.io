# CGINCLUDE ENDCG

因为有多可能有 pass，这条语句可以声明全局 pass 都公用的内容

```HLSL
CGINCLUDE
#pragma target 3.0
#include "UnityCG.cginc"
ENDCG
```