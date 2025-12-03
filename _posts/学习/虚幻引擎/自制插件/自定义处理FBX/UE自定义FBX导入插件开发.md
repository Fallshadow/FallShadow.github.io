# 读取 FBX

FBXParserLibrary 

## FbxManager

创建全局静态变量 FbxManager （其需要 FbxIOSettings）

加载插件后，在解析 FBX 时获取或创建，在插件退出时卸载

## ParseFBXFile

解析 FBX 文件

### ParseFbxNodeProperties

这里解析 FBX 中的自定义属性

# TODO 利用 FBX 生成 Mesh

自发光 mesh 直接使用 FBX 内的数据生成面片，相当于修缮了导入的 FBX。

这部分工作可以放在 DCC 那边。DCC 不想放，就程序这边自己生成咯。

# 导出 json

WriteFBXDataToJSON

TODO: 没有此属性的 FBX 初始值需要关注设置

# TODO 解析 json

解析 json 为可用的

# TODO 直接解析 FBX

其实可以省略导出 json 这一步（如果不想看中间过程步骤，提升导入速度）

出现问题时，为方便排查哪一步出错，还可以回到导出 json 那一步，看看 json 数据