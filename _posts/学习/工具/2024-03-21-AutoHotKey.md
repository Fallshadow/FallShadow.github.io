---
layout: post
title:  "AutoHotKey"
date:   2024-03-21
categories: 工具
excerpt_separator: ""
---

AutoHotKey是一款按键辅助工具。可以实现自定义按键映射、自动点击、自动按键等功能。  

[1 下载使用](#下载使用)  
[2 常用基础语法](#常用基础语法)  
&emsp;[2.1 注释](#注释)  
&emsp;[2.2 快捷键映射语法](#快捷键映射语法)  
&emsp;[2.3 特殊字符](#一些需要特殊处理的字符输出)  

## 下载使用
[官网](https://www.autohotkey.com/)下载安装之后。在任意位置创建以.ahk结尾的文件即可。编写完内容后，直接运行此ahk，它就会在后台运行程序。  
```
CapsLock & w::send,{up}
CapsLock & a::send,{left}
CapsLock & d::send,{right}
CapsLock & s::send,{down}
```
像这样，就把大写键+wasd映射为上下左右。

对应文档在官网也有，而且有[中文版](https://wyagd001.github.io/zh-cn/docs/index.htm)。

## 常用基础语法
#### 注释
以分号开头的行为注释，也可以使用/**/进行多行注释。  
一行命令之后想要注释，请使用空格加分号。  
```
; CapsLock & w::send,{up}
/*
CapsLock & a::send,{left}
CapsLock & d::send,{right}
*/
CapsLock & s::send,{down} ;
```
#### 快捷键映射语法
```Cpp
按键A & 按键B :: 
效果X
效果Y
效果Z
return
;很像函数，::之前是操作，::之后是具体要做啥


按键A & 按键B :: 效果X ;此行一行就是一个映射，无需return
```

#### 一些需要特殊处理的字符输出
分号是注释符，如果要使用它，需要转义字符'`'，如果要输出它使用{text}
```Cpp
`;::
send {text};
send {text}``````
return
```



