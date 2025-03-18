
# 原则

1. 不再直接处理资源，而是使用 RenderGraph 特定句柄，所有 RenderGraphAPI 都使用这些句柄操作资源。RenderGraph 管理的资源类型是 RTHandles、ComputeBuffers 和 RendererLists。
2. 实际资源引用只能在 RenderPass 的执行代码中访问；该框架需要显示声明 RenderPass。每个 RenderPass 必须声明它的读取/写入哪些资源；
3. RenderGraph 每次执行之间不存在持久性。这意味着你的 RenderGraph 的一次执行中创建的资源无法延续到下一次执行；对于需要持久性的资源（例如从一帧到另一帧），你可以在 RenderGraph 之外创建他们，然后将他们导入。
4. 在依赖项跟踪方面，他们的行为与任何其他 RenderGraph 资源类型类似，但 RenderGraph 不处理他们的生命周期。
5. RenderGraph 主要用 RTHandles 纹理资源。这对于如何编写着色器代码以及如何设置他们有很多影响。

# 时间线

## 录制时间线

通过代码声明输入输出、声明全局状态修改、传递剔除标记、设置资源依赖、同时设置执行回调的渲染函数、并设置 pass data 将外部参数传递到渲染函数内的过程

## 执行时间线

根据录制时间线的依赖项执行录制线中设置好的渲染函数。  
当然录制时间线与执行时间线并不是每个阶段和依赖项都是一一对应的。render graph 会根据录制时间线传递的
剔除标记与资源依赖来确定是否某个需要执行的 render graph pass 可以被剔除。  

那些没有被剔除的阶段一旦执行，会读取录制时间线阶段中设置的 pass data，并通过图形命令来进行渲染呈现这个过程的细节。