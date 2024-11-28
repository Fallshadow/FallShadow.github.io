加载清单文件 file.txt

    拿着路径名 D:/FallShadow/AssetDB/sandbox 初始化函数请求 FileTask
    文件加载完成后，逐行获取信息，构建出 hash2normal，resourceBundleFilePaths，url2AssetInfo
    hash2normal                     arts/ui/common_e008b60554bedf187f25c8b0bc5a0c3e.bundle -> arts/ui/common.bundle
    resourceBundleFilePaths列表     arts/ui/common_e008b60554bedf187f25c8b0bc5a0c3e.bundle
    url2AssetInfo                   asset://arts/ui/common.bundle -> 资源详情（Bundle 类型）
                                    asset://arts/ui/common.bundle/ -> 资源详情（Bundle 类型）
    bundleKey2Assets                arts/ui/common.bundle -> 形如 asset://arts/ui/common/icon_load_null.jpg 的资源列表
    url2AssetInfo                   asset://arts/ui/common.bundle -> 资源详情
                                    asset://arts/ui/common.bundle/ -> 资源详情
                                    asset://arts/ui/common/icon_load_null.jpg -> 资源详情（BundleAsset 类型）
    
    第一次加载第一个场景 asset://Res/Scenes/Entry.unity loadmode
    url2SceneInfo 记载 url 对应加载 mode 等场景信息。
    url2handle 没找到缓存，创建 AssetTask 任务。
    handleManager 创建 handle，从 freeHandle 最后一个位置获取数据，作为 index，freehandle 的 index 是倒置的，从 1 开始
    url2handle 添加 handle
    refCounts 创建 handle index 计数

    TickRequestEditorAssetTasks
    拿到任务的 url 进行解析
    创建资源 Cache
    发现后缀是场景，搜索 url2SceneInfo 找到之前放入的场景信息。
    UnityEditor.SceneManagement.EditorSceneManager.LoadSceneInPlayMode 加载场景同时创建 requestEditorSceneTasks
    正式将 Cache 放入 assetCaches



当一个资源的 inspector 有引用其他资源，并且这些“其他资源”也有在 .pkg 规划内，这时候就需要 deps 文件额外记录这个资源以来的“其他资源”们，以防止资源的重复（如果不记录而是像“其他资源”不在 .pkg 规划内的情况下，将其引用资源直接包含在资源本体时，就会出现资源冗余多次加载重复资源以至于资源包不可控地过大）



究其根本，Editor 下，加载资源使用 AssetBundle.LoadFromFileAsync 接口加载本地磁盘路径文件。

