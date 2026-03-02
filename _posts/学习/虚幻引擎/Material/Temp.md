# Texture Sample

## MipValueMode

- None（默认）
让 GPU 自动用屏幕导数（ddx/ddy）计算 LOD；最常用、最稳。

- MipLevel / MipLevel (Absolute)
你直接指定用第几级 mip（0=最清晰）。用于特殊效果/调试/固定分辨率采样；不随距离变化。

- MipBias
在自动 LOD 基础上加一个偏移：
Bias > 0 更糊更稳，Bias < 0 更锐但更易闪烁。

- Derivative / DDX/DDY（有的版本叫 Derivative 或 Explicit Derivatives）
你显式提供 UV 的 ddx、ddy，让采样用你给的导数来算 LOD。用于自定义 UV 扭曲、程序化映射、避免错误 LOD。

## 