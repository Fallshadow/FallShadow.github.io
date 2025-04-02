- [CMD](#cmd)
- [获取远点在摄像机近平面的投影点](#获取远点在摄像机近平面的投影点)
- [GC handle 报错](#gc-handle-报错)
- [下载全球版本](#下载全球版本)
- [自动设置脚本文件为 utf8](#自动设置脚本文件为-utf8)
  - [DidReloadScripts 方法](#didreloadscripts-方法)
  - [AssetPostprocessor 导入文件格式处理](#assetpostprocessor-导入文件格式处理)
  - [模板文件](#模板文件)
  - [VS .editorconfig 配置 utf-8 编码](#vs-editorconfig-配置-utf-8-编码)
  - [Git 的编码配置](#git-的编码配置)

## CMD

```Cpp
string path = Application.dataPath + "/../GenCsharp/";

Process proc = new();

proc.StartInfo.FileName = path + "SyncGenCsharp.bat";
proc.StartInfo.WorkingDirectory = path;
proc.StartInfo.CreateNoWindow = true;
proc.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
proc.EnableRaisingEvents = true;

proc.Start();
proc.WaitForExit();
```

## 获取远点在摄像机近平面的投影点

```Cpp
    public static Vector3 GetCameraPlaneProjectWorldPos(Vector3 oriWorldPos, float distanceToCamera) {
        Camera camera = Camera.main;
        Matrix4x4 viewMatrix = camera.worldToCameraMatrix;
        Vector3 posInCamera = viewMatrix.MultiplyPoint(oriWorldPos);

        distanceToCamera = -distanceToCamera;
        float x1 = posInCamera.x * distanceToCamera / posInCamera.z;
        float y1 = posInCamera.y * distanceToCamera / posInCamera.z;
        float z1 = distanceToCamera;
        Vector3 result = new Vector3(x1, y1, z1);

        Matrix4x4 inverseViewMatrix = camera.cameraToWorldMatrix;
        Vector3 resultworldPosition = inverseViewMatrix.MultiplyPoint(result);
        return resultworldPosition;
    }
```

```Cpp
using System;
using System.Collections.Generic;
using UnityEngine;

class CameraProjectTest : MonoBehaviour {
    private List<Vector3> oriPos = new List<Vector3>();

    private void Update() {

        if (Input.GetKey(KeyCode.W)) {
            if (Input.GetMouseButtonDown(0))
            {
                // 获取鼠标点击的屏幕坐标  
                Vector3 mousePosition = Input.mousePosition;

                // 创建一条从摄像机发出的射线  
                Ray ray = Camera.main.ScreenPointToRay(mousePosition);

                Plane plane = new Plane(Vector3.up, Vector3.zero);
                RaycastHit hit;

                if (plane.Raycast(ray, out float enter)) {
                    // 计算交点的世界坐标  
                    Vector3 hitPoint = ray.GetPoint(enter);

                    GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                    cube.transform.position = hitPoint;
                    oriPos.Add(hitPoint);

                    Vector3 pos = CommonUtil.GetCameraPlaneProjectWorldPos(hitPoint, 2);

                    GameObject Sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    Sphere.transform.position = pos;
                    Sphere.transform.localScale = new(0.1f, 0.1f, 0.1f);
                }
            }
        }
    }

    void OnDrawGizmos() {
        // 设置 Gizmo 的颜色  
        Gizmos.color = Color.red;

        foreach (var p in oriPos) {
            // 绘制从 A 点到 B 点的连线  
            Gizmos.DrawLine(p, Camera.main.transform.position);
        }

        // 设置 Gizmo 的颜色  
        Gizmos.color = Color.green;
    }
}
```

## GC handle 报错

Release of invalid GC handle. The handle is from a previous domain. The release operation is skipped.

随便重新编译一下脚本就可以了

## 下载全球版本

第一步： 下载 UnityHub 全球版本

可以从我的百度网盘下：

链接：https://pan.baidu.com/s/1zdGeRibrzI6Ok2I6Yxv6CA 提取码：u8f9 

第二步：在任意浏览器中打 UnityHub://协议+版本号，如：

Unityhub://2022.3.59f1

Unityhub://6000.0.40f1

Unityhub://6000.1.0b8

Unityhub://6000.2.0a4

## 自动设置脚本文件为 utf8

### DidReloadScripts 方法

 当 Unity 的脚本编译完成并重新加载时，会调用标记了这个属性的方法

 ```Cpp
    [DidReloadScripts]
    private static void OnScriptsReloaded() {
        string[] scriptPaths = Directory.GetFiles(Application.dataPath, "*.cs", SearchOption.AllDirectories);
        foreach (var scriptPath in scriptPaths) {
            var content = File.ReadAllText(scriptPath);
            File.WriteAllText(scriptPath, content, new System.Text.UTF8Encoding(false));
        }
    }
 ```

 这种办法会遍历所有的脚本文件，效率低。

### AssetPostprocessor 导入文件格式处理

```Cpp
using System.IO;
using UnityEditor;
using UnityEngine;

public class ScriptEncodingFixer : AssetPostprocessor {

    // 当新文件导入时触发  
    private static void OnPostprocessAllAssets(
        string[] importedAssets,
        string[] deletedAssets,
        string[] movedAssets,
        string[] movedFromAssetPaths) {
        foreach (string assetPath in importedAssets) {
            // 只处理 .cs 文件  
            if (Path.GetExtension(assetPath) == ".cs") {
                FixScriptEncoding(assetPath);
            }
        }
    }

    // 修复脚本文件的编码  
    private static void FixScriptEncoding(string assetPath) {
        string fullPath = Path.Combine(Directory.GetCurrentDirectory(), assetPath);

        // 读取文件内容  
        string content = File.ReadAllText(fullPath);

        // 检查文件是否已经是 UTF-8 编码  
        if (!IsUtf8WithoutBom(fullPath)) {
            // 重新保存为 UTF-8 编码（不带 BOM）  
            File.WriteAllText(fullPath, content, new System.Text.UTF8Encoding(false));
            Debug.Log($"Script encoding fixed: {assetPath}");
        }
    }

    // 检查文件是否为 UTF-8 编码（不带 BOM）  
    private static bool IsUtf8WithoutBom(string filePath) {
        byte[] buffer = File.ReadAllBytes(filePath);

        // 检查是否有 BOM（前三个字节为 EF BB BF）  
        if (buffer.Length >= 3 && buffer[0] == 0xEF && buffer[1] == 0xBB && buffer[2] == 0xBF) {
            return false; // 带 BOM，不符合要求  
        }

        try {
            // 尝试用 UTF-8 解码  
            System.Text.Encoding.UTF8.GetString(buffer);
            return true; // 是 UTF-8 且不带 BOM  
        }
        catch {
            return false; // 不是 UTF-8  
        }
    }
}
```

### 模板文件

C:\Program Files\Unity\Editor\Data\Resources\ScriptTemplates

这个文件格式确保

### VS .editorconfig 配置 utf-8 编码  

root = true  

[*.cs]  
charset = utf-8  

### Git 的编码配置

.gitattributes 文件

```Cpp
*.cs text eol=lf  
*.cs text working-tree-encoding=UTF-8  
```

保存后，Git 会强制将所有 .cs 文件保存为 UTF-8 编码。
