# asset package 文档

## 从示例开始学习

https://git.sofunny.io/engine/packages/com.sofunny.asset/-/blob/asset-for-webgl/Assets/com.sofunny.asset/README.md

打包的示例可以拉下对应 tag 的这个工程，本身就是一个unity 工程哈 

![](Images/1.png)

- Mount 指定资源存放路径。指定之后，我们的资源路径 key 就是相对于这个路径下的子路径。使用 asset:// 代指。比如我们将 main.prefab 资源打包到了项目的 sandbox 下的 arts/ui/panels/sprites_bee2f4da6f7bfc59818f57eb5efed52d.bundle 这份 bundle 里。然后我们可以将 Mount 设置为 "/../sandbox" 。这样我们在使用 ab.load 时，就可以这样调用 "asset://arts/ui/panels/main.prefab" 。 

    ```Cpp
    db.Mount($"{Application.dataPath}/../sandbox");
    mainHandle = db.Load($"asset://arts/ui/panels/main.prefab");
    ```

    ![](Images/2.png)

- SetFilesUrl 资源清单。资源管理系统依据这个清单建立起 bundle 和实际资源的关系。之后我们使用 ab.load 加载就可以通过 url 找到对应资源

- SetSpecialDirectory 小游戏远程资源清单。




打包出微信小游戏，发现资源无法加载，这个时候，请确定你的微信没有缓存清单文件，如果微信缓存了清单文件，很可能这次找的资源是上次的，这样就不行了。
