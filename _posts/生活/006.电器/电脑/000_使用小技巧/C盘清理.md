- [根目录下](#根目录下)
  - [hiberfil.sys](#hiberfilsys)
  - [pagefile.sys](#pagefilesys)
- [基础清理](#基础清理)
- [Users](#users)
  - [NVIDIA](#nvidia)
  - [unity](#unity)
- [Windows](#windows)
  - [Temp](#temp)
  - [SoftwareDistribution](#softwaredistribution)
  - [WinSxS](#winsxs)
  - [DriverStore](#driverstore)
- [杂项目录](#杂项目录)
  - [C:\\Autodesk](#cautodesk)

# 根目录下

## hiberfil.sys

hiberfil.sys 是 Windows 的休眠文件，在你启用“休眠”功能时，系统会把内存里的所有数据存到这个文件里，这样你下次开机就能快速恢复到之前的工作状态

请不要直接选中这个文件按 Delete 键，因为系统会锁定它，你可能删不掉，甚至会收到报错提示。正确的方法是使用命令关闭休眠功能，文件就会自动消失：
- 在任务栏搜索 cmd，在“命令提示符”上点击右键，选择“以管理员身份运行”。
- 在弹出的黑色窗口中，输入以下命令 powercfg -h off
- 执行后不会有成功提示，但你会发现 C 盘下的 hiberfil.sys 文件已经立刻消失了，空间也腾出来了。
- 如果哪天你改变主意，想重新启用，用管理员身份再运行 powercfg -h on 就能恢复

## pagefile.sys

pagefile.sys 是 Windows 的虚拟内存文件。当你的物理内存（RAM）快用满时，系统会把暂时不用的数据临时挪到这个文件里，给新程序腾出物理内存空间。

你可以把它移到另一个空间充裕的非系统盘（比如 D 盘），或者你觉得物理内存绝对够用（比如 32GB 或以上），想在 C 盘留个小一点的应急，也可以手动调整。操作步骤如下

1. 同时按下键盘上的 Win + R 键，打开“运行”对话框。
2. 输入 systempropertiesadvanced，然后按回车键。
3. 这样会直接打开“系统属性”窗口，并且自动定位在“高级”选项卡。

现在，你可以在列表里为每个盘设置虚拟内存：
- 要移走 C 盘的：选中 C: 盘，然后选择下面的“无分页文件”，再点击旁边的“设置”按钮。
- 放到 D 盘去：再选中 D: 盘，选择“系统管理的大小”（推荐），然后点击“设置”按钮。
- 最后一路点击“确定”，重启电脑后设置就会生效。重启后，你会发现 C 盘下的 pagefile.sys 文件已经消失或变小，而 D 盘下则会出现一个新的。

# 基础清理

在开始菜单搜索并打开 “磁盘清理”。点击 “清理系统文件”，然后在下拉列表中勾选 “Windows 更新清理”，点击确定即可。这可以清理掉安装系统更新后留下的旧版本文件。

下拉选择中可以视大小情况，选择很多我们不需要的

# Users

## NVIDIA

C:\Users\[用户名]\AppData\Local\NVIDIA 是 NVIDIA 显卡驱动用来存放临时缓存和日志的地方

DXCache：DirectX 着色器缓存，为了加速游戏而生成的。

GLCache：OpenGL 着色器缓存，原理和上面类似。

NV_Cache：同样是着色器或相关内容的缓存

## unity

C:\Users\FallShadow\AppData\Local\Unity\cache

package cache 和 GI cache

# Windows

这下面的一般都比较重要

## Temp

定期清理

## SoftwareDistribution

Windows Update 的下载缓存。更新失败或想腾空间时，可以安全删除。操作前需先在服务里停掉 Windows Update 服务，删完再启动。

但是一般也不会很大

## WinSxS

C:\Windows\WinSxS 文件夹是 Windows 系统最核心的组件仓库，你可以把它理解为操作系统的“零件总仓”和“档案库”。

里面的内容绝对不能手动删除或移动，但可以通过系统自带的工具进行安全清理

## DriverStore

C:\Windows\System32\DriverStore\FileRepository\

驱动档案库，不敢动不敢动

# 杂项目录

## C:\Autodesk

这个 C:\Autodesk\WI 文件夹可以放心清理，它只是欧特克（Autodesk）软件的安装临时文件。