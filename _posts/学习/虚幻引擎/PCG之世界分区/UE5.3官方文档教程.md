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

由于每个Grid中的CellSize是固定的，对于一些较大的 Actor，包围盒可能横跨多个 Cell，这种情况下我们可以将原本的 CellSize 翻倍作为一级新的 GridLevel，重新进行判断，如果还不能包含则依次类推，直到找到能包含该 Actor 的 GridLevel (最大一级 GridLevel Cell 的尺寸与地图大小相当，一定能包含该 Actor )。

我们可以在 World Setting 面板中添加多个Grid相关设置，所有 Grid 会在游戏运行时同时生效。

这里的 Grid Name 即为 Gird 的唯一标识，不同的 Grid 可以拥有不同的 Cell Size和Loading Range，方便不同类型的物体使用不同的加载策略。

## 使用体积加载

## 生成小地图

编辑器下预览用

## 生成 HLOD

### 分配 HLOD

### 预览 HLOD


# 性能检测

## 运行后 Log

WP 的逻辑是在 World::BeginPlay 时开始动态划分的，具体的划分结果，可以在 Saved/Log/WorldPartition/ 路径下找到详细的 log

即地图运行之后，UE 会生成一个 StreamingGeneration 的 log 文件，记录了地图的网格划分信息，包括网格单元的数量，网格单元的详细信息等，我们可以通过这个 log 文件来初步了解地图的网格划分情况，从而评估世界分区的性能开销。

日志信息主要包括三个部分：
- Containers ： 场景中所有ActorDesc简要信息和Clusters信息，以及场景本身的基本信息
- 场景中Persistent Level已经放置的Actor对应的Path和Package （Always loaded Actor Count: 214 始终加载的Actor数量，及Actor名字）
- 场景中每个Grid具体的GridLevel划分情况，以及每一级GridLevel中每个Cell中具体包含的Actor。这部分方便我们排查分配结果是否符合预期，是我们主要关注的部分。XXXXX_MainGrid_L1_X1_Y3 或者说 关卡名称_设置的Grid名字_L0_X-3_Y-1_Z0 ： 名字中的L0表示Cell的分级，除了明面上的Grid分层，UE实际上对Grid中的Cell还会再分级，根据Actor包围盒的大小，会将Cell划分为不同大小的Cell，L0表示最底层的Cell，L1表示下一级Cell，以此类推，L0的Cell最小，L1次之，以此类推，正常来说，应该尽可能减少级别，因为当一个Cell过于大时，它基本上是始终加载的，也就失去了流送的意义和价值，不如直接将里面的Actor设置为始终加载，从而减少网格遍历本身的开销。

在 5.3 版本的引擎可以使用 wp.Editor.DumpStreamingGenerationLog 命令在不运行游戏的情况下进行一次划分操作并输出日志。

## 运行时监测

运行时，可以输入控制台指令：wp.Runtime.ToggleDrawRuntimeCellsDetails，查看每个网格单元加载的耗时信息。

在控制台输入 Stat Streaming ，查看网格加载和卸载情况。

Unreal Insights 工具分析

# 优化实践

## 动态加载策略：

根据玩家行为动态调整流送策略，例如：

飞行时加载更大范围的网格单元。

地面移动时减少加载范围。