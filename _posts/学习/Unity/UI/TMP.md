https://blog.csdn.net/qq_30144243/article/details/135988104

https://github.com/wy-luke/Unity-TextMeshPro-Chinese-Characters-Set/tree/main

3500 和 7000 汉字 自己酌情选择

然后配置方面，Padding 一般 5 ，Packing Method 一般 Fast，Render Mode 一般 SDFAA， 分辨率 最大那个。

图片字体，TMP_Sprite Asset，图片颜色可以更改。

```Cpp
<sprite=10 color=#FF0000> // 指定颜色
<sprite=10 tint=1 color=#FFFFFF> // 跟随字体组件设置的颜色
```

## ttf 查看所有字符 查看字体字符

win + R  charmap

安装完ttf ，就可以在里面找到，然后搜索复制字体

其实双击 ttf 打开也可以看个大概

## 动态字体更改源字体不生效问题

估计是缓存的部分没有生效，需要点击 Clear Dynamic Data，然后会有提示让你是不是要重新生成
