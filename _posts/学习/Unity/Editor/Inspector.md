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

## 显示不被序列化的内容

