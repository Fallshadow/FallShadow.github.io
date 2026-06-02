# Linear

需要将颜色空间设置为 Linear 线性空间

拿我们开发游戏用到的图片来说，基础颜色图一般都是 gamma 空间的图片，导入到 unity 就应该用 gamma 空间解析显示，在图片设置的 sRGB 选项就意思是使用 gamma 解析这个图片。然而像金属度粗糙度这些图片一般都是线性空间下的，在 sp 等软件导出时一般都设置为线性空间的了，所以导入到 unity 中就不需要勾选 sRGB 按钮。

# 后处理

- AO            自遮挡的阴影效果 
- Bloom         泛光效果
- HDR           动态范围光
- ACES          HDR to LDR 色调映射
- Saturation    饱和度
- Vignette      压暗

# 预览效果

可以不开启 skybox 查看效果