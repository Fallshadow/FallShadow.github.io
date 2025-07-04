在典型的计算机环境中，应用程序运行时会启动一个窗口管理器，窗口管理器决定每一个应用在屏幕上的显示区域，并通过窗口浏览器实施显示和交互。应用程序调用图形平台 API，在窗口内的客户区域进行绘制，图形平台则通过驱动 GPU 来回应程序调用，完成所需的绘制。

2D 图形平台形成了两种不同目标和功能的架构：即时模式（IM）和保留模式（RM）。

即时模式下程序员的工作：当要对绘制图像做任何修改时，让场景生成器遍历 AM，重新生成表示场景的基元集合。
即时模式平台的精简特性对以下人员有吸引力：想要尽可能让其编程贴近图形硬件以获取最大化性能的应用程序开发人员，以及想要让其产品占用的资源尽可能少的人。

保留模式平台在一个专门的数据库中保留了需要绘制或观看的场景表示，我们称其为场景图。
任何增量式的修改都会导致客户端的更新。由于保留了整个场景，平台还能承担许多与用户交互相关的常见任务。
