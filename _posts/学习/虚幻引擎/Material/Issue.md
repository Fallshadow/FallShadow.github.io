# 材质引用替换问题

UE 引擎中原本有一个材质 A，有很多三个网格体引用这个材质 A，现在我新建了一个材质 B，我想让这三个网格体从使用材质 A，换到使用材质 B，有什么便捷方法么？

答案就是资源操作 ： 
- Content Browser 里找到材质 A
- 右键 Asset Actions → Replace References…
- 选择用 B 替换并确认

# MRO正确设置

正确的设置 MRO 应该是 masked no sRGB 这样才会采用正确的压缩，正确的效果

因为如果开了 sRGB 会被 gamma 处理，这会导致数据出问题