你可以用经纬度等真实坐标来定义场景原点，让UE里的物体能准确对应到地球上的某个具体位置



- 启用插件：在 编辑（Edit） > 插件（Plugins） 中搜索并启用 Georeferencing 插件。
- 放置Actor：通过 放置Actor（Place Actors） 面板，将 Geo Referencing System Actor 拖入关卡
- 配置属性：选中这个Actor，在细节面板设置几个关键属性
  - 行星形状：根据项目规模选 Flat Planet（小场景）或 Round Planet（大场景/全球）
  - 坐标系：为投影CRS或地理CRS填入EPSG代码（如EPSG:4326表示WGS84经纬度），UE底层用PROJ库支持这些定义
  - 原点位置：设置UE关卡原点对应的真实地理坐标（经纬度/海拔，或投影坐标东/北偏移）
核心功能：配置好后，插件提供函数让你在 UE引擎坐标、投影坐标、地理坐标 和 地心（ECEF）坐标 之间自由转换

