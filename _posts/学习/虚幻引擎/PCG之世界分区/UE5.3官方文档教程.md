- [OFPA](#ofpa)
  - [如何启用](#如何启用)
  - [子关转换](#子关转换)
- [开放世界地图](#开放世界地图)
  - [Actor 设置](#actor-设置)
  - [WorldPartitionStreamingSource](#worldpartitionstreamingsource)
  - [运行时网格](#运行时网格)
    - [Grid 设置](#grid-设置)
  - [使用体积加载](#使用体积加载)
  - [生成小地图](#生成小地图)
  - [生成 HLOD](#生成-hlod)
    - [分配 HLOD](#分配-hlod)
    - [预览 HLOD](#预览-hlod)
- [性能检测](#性能检测)
- [](#)
  - [运行时监测](#运行时监测)
- [优化实践](#优化实践)
  - [动态加载策略：](#动态加载策略)
- [Level Instancing](#level-instancing)
  - [两种关卡实例](#两种关卡实例)

# OFPA

one file per actor 每个演员一个文件，最大化提高团队处理演员的速度，即一个人在改这个 actor，另一个人可以去改另一个 actor，而不必等待。

“每个演员一个文件” 功能仅在编辑器中提供效用。而在运行时，所有演员都会嵌入在各自的关卡文件中。

## 如何启用

world setting 里 开启 Use External Actors

已经是开放世界或者已经是开启 wp 的世界，默认就会开启这个选项

## 子关转换

这个选项只针对当前世界，对子世界不起作用。

官方也有工具可以一键进行转换

# 开放世界地图

## Actor 设置

受管理的物体 运行时网格（Runtime Grid） 和 是否空间加载（Is Spatially Loaded）

## WorldPartitionStreamingSource

传送流的主角控制器 启用流送源（Enable Streaming Source）

传送点 WorldPartitionStreamingSource 组件

## 运行时网格

黑客帝国例子

### Grid 设置

由于每个 Grid 中的 CellSize 是固定的，对于一些较大的 Actor，包围盒可能横跨多个 Cell，这种情况下我们可以将原本的 CellSize 翻倍作为一级新的 GridLevel，重新进行判断，如果还不能包含则依次类推，直到找到能包含该 Actor 的 GridLevel （最大一级 GridLevel Cell 的尺寸与地图大小相当，一定能包含该 Actor )。

我们可以在 World Setting 面板中添加多个 Grid 相关设置，所有 Grid 会在游戏运行时同时生效。

这里的 Grid Name 即为 Gird 的唯一标识，不同的 Grid 可以拥有不同的 Cell Size 和 Loading Range，方便不同类型的物体使用不同的加载策略。

## 使用体积加载

## 生成小地图

编辑器下预览用

## 生成 HLOD

### 分配 HLOD

### 预览 HLOD

# 性能检测

#

## 运行时监测

运行时，可以输入控制台指令：wp.Runtime.ToggleDrawRuntimeCellsDetails，查看每个网格单元加载的耗时信息。

在控制台输入 Stat Streaming ，查看网格加载和卸载情况。

Unreal Insights 工具分析

# 优化实践

## 动态加载策略：

根据玩家行为动态调整流送策略，例如：

飞行时加载更大范围的网格单元。

地面移动时减少加载范围。

# Level Instancing

## 两种关卡实例