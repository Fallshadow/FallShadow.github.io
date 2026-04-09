- [meshData](#meshdata)
- [v2fData](#v2fdata)
- [vert](#vert)
- [frag](#frag)
  - [semantic 固定关键字语义 ： SV\_Target](#semantic-固定关键字语义--sv_target)
    - [MRT 多渲染目标](#mrt-多渲染目标)
  - [semantic 固定关键字语义 ： VFace](#semantic-固定关键字语义--vface)


# meshData

# v2fData

# vert

# frag


## semantic 固定关键字语义 ： SV_Target

SV_Target → 告诉 GPU：“把这个值写到渲染目标（Render Target）上”

```HLSL
float4 frag(...) : SV_Target
```

### MRT 多渲染目标

```HLSL
float4 frag(...) : SV_Target0
float4 frag2(...) : SV_Target1
```

SV_Target0 → 第一个缓冲
SV_Target1 → 第二个缓冲

## semantic 固定关键字语义 ： VFace

把 “正面/背面信息” 传给这个变量，一般这样用：

```HLSL
float4 frag(V2FData pixel,float isFrontFace:VFace) : SV_Target
```


