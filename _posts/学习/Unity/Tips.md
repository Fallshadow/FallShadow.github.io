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
