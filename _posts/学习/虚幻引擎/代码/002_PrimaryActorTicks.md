timer tick actortick 

## 概念

这是每个 Actor 都有的 Tick 函数管理器，控制该 Actor 的每帧更新行为。

## 控制 Tick 的开关和行为

// 是否允许这个 Actor 执行 Tick
PrimaryActorTick.bCanEverTick = true;

// 是否在游戏开始时自动启用 Tick
PrimaryActorTick.bStartWithTickEnabled = true;

## 设置 Tick 的执行时机

// 设置 Tick 在哪个阶段执行（物理前/后等）
PrimaryActorTick.TickGroup = TG_PrePhysics;  // 物理模拟前
PrimaryActorTick.TickGroup = TG_DuringPhysics; // 物理模拟期间
PrimaryActorTick.TickGroup = TG_PostPhysics;   // 物理模拟后

## 控制是否在特定情况下 Tick

// 即使暂停游戏也继续 Tick（用于UI等）
PrimaryActorTick.bTickEvenWhenPaused = false;

// 允许在编辑器中 Tick（预览动画等）
PrimaryActorTick.bAllowTickOnDedicatedServer = true;

## 完全禁用 Tick

PrimaryActorTick.bCanEverTick = false;      // 永远不 Tick
PrimaryActorTick.bStartWithTickEnabled = false; // 启动时也不启用

## 默认情况

### 普通 Actor（AActor）

bCanEverTick = false;         // 默认不Tick
bStartWithTickEnabled = true; // 但如果启用，自动开始

### 角色（ACharacter）

bCanEverTick = true;          // 角色默认需要Tick
bStartWithTickEnabled = true;

### Pawn（APawn）

bCanEverTick = true;          // Pawn默认需要Tick
bStartWithTickEnabled = true;

### 控制器（AController）

bCanEverTick = true;          // 控制器默认需要Tick
bStartWithTickEnabled = true;

## 自主管理

如果你有一个需要间隔管理的管理器，你还是使用 timer 比较合适。

tick 维护成本高，开销更大 timer 轻量独立

官方文档明确指出： "If your update doesn't need to run every frame, use a Timer instead of Tick."