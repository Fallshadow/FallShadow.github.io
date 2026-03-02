直接搜索[官方文档](https://dev.epicgames.com/documentation/zh-cn/unreal-engine/geographically-accurate-sun-positioning-tool-in-unreal-engine)


SunPositionCalculator

# 自制月亮

在低于 UE 5.6 版本的情况下，无法使用天穹。

如果想实现月亮需要手动调节。

## 新建月亮

- 拖一个 Directional Light 
- Mobility：Movable
- Intensity​：0.022
- Light Color​：稍微偏冷一点的蓝灰色
- Atmosphere Sun Light Index：设为 1 （多数默认天空/云材质和蓝图只读槽位 0 的光，散射和云控制重心也在槽位 0，槽位 1 属于额外加成）（个人感觉最大的变化是大气变亮了不是黑成一片了）
- Forward Shading Priority：谁大就用谁的光，这个选项建议在夜晚月亮大，白天太阳大
- Source Angle：一般设置为 0.1 左右，让阴影更加锐利。（没啥感觉，因为太阳用的 0.53 多，没差太多，调节到 100 倒是能看到 100 很糊）

## 同步更新月亮位置

![alt text](更新月亮位置.png)

## 月亮贴图