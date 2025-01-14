

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
        // 设置Gizmo的颜色  
        Gizmos.color = Color.red;

        foreach (var p in oriPos) {
            // 绘制从A点到B点的连线  
            Gizmos.DrawLine(p, Camera.main.transform.position);
        }

        // 设置Gizmo的颜色  
        Gizmos.color = Color.green;
    }
}
```



## GC handle 报错

Release of invalid GC handle. The handle is from a previous domain. The release operation is skipped.

随便重新编译一下脚本就可以了