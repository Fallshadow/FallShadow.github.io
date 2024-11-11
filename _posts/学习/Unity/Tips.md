## 工具栏功能

```Cpp
[MenuItem("Tools/Build AB")]
```

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


## 显示属性

```Cpp

public class DisplayNameAttribute : PropertyAttribute {
    public string DisplayName { get; private set; }

    public DisplayNameAttribute(string displayName) {
        DisplayName = displayName;
    }
}

using UnityEditor;

[CustomPropertyDrawer(typeof(DisplayNameAttribute))]
public class DisplayNameDrawer : PropertyDrawer {
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
        DisplayNameAttribute displayNameAttribute = (DisplayNameAttribute)attribute;
        label.text = displayNameAttribute.DisplayName;
        EditorGUI.PropertyField(position, property, label);
    }
}

    [Header("测试怪物技能")]
    [DisplayName("敌人不再生成")]
    public bool enemyTest = false;
    [DisplayName("敌人血量变厚")]
    public bool hardEnemy = false;
    [DisplayName("按Q生成指定ID敌人，左shift+Q连续生成")]
    public int enemyIDTest = 1001;
    [DisplayName("为新生成的敌人添加指定ID技能，默认0为不添加")]
    public int enemySkillTest = 1003;
    [Header("测试指定关卡")]
    [DisplayName("关卡不再锁定")]
    public bool levelTest = false;
    [DisplayName("进入指定关卡")]
    public int levelID = 1;
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

