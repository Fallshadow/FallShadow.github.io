---
layout: post
title:  "Hazel-13-Docking"
date: 2024-04-16
categories: 游戏引擎
excerpt_separator: ""
---

切换到docking分支，这里cherno节点为 cf5a93a

这里我们将imgui例子中的渲染通过include的方式放到imguibuildcpp中，记得修改我们之前修改过的头引用。

切换到docking之后，我们就不用再通过监听imguoio事件去交互imgui了，docking是这样的。
