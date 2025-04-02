
- [原则](#原则)
- [时间线](#时间线)
  - [录制时间线](#录制时间线)
  - [执行时间线](#执行时间线)
- [执行过程](#执行过程)
  - [setup](#setup)
  - [completion](#completion)
  - [execution](#execution)
- [Pass](#pass)
  - [RenderGraphPass](#rendergraphpass)
  - [UnsafeRenderGraphPass](#unsaferendergraphpass)
  - [RasterRenderGraphPass](#rasterrendergraphpass)
  - [ComputeRenderGraphPass](#computerendergraphpass)
- [RTHandle System](#rthandle-system)
  - [什么是 RTHandle System](#什么是-rthandle-system)
- [Native Render Pass](#native-render-pass)
  - [不开启 Native Render Pass 的渲染情况](#不开启-native-render-pass-的渲染情况)
  - [开启 Native Render Pass 的渲染情况](#开启-native-render-pass-的渲染情况)
  - [手动管理 deep RT](#手动管理-deep-rt)
  - [targetAART](#targetaart)
- [材质属性封装](#材质属性封装)
- [自定义 Unlit Shader GUI](#自定义-unlit-shader-gui)
- [自定义 RenderPipeline Assets Editor 实现 SrpBatcher 功能配置](#自定义-renderpipeline-assets-editor-实现-srpbatcher-功能配置)
  - [RenderPipeline Assets 编辑器的实现](#renderpipeline-assets-编辑器的实现)
- [新功能的四部分工作](#新功能的四部分工作)
- [主光源阴影](#主光源阴影)
- [小知识](#小知识)
  - [为什么 URP 管线下，天空盒渲染要在不透明物体和透明物体之间](#为什么-urp-管线下天空盒渲染要在不透明物体和透明物体之间)

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

那些没有被剔除的阶段一旦执行，会读取录制时间线阶段中设置的 pass data，并通过图形命令来进行渲染呈现。

# 执行过程

render graph 的执行过程就是通过 setup 构建、completion 编译与 execution 执行这些 pass 来完成的。

## setup

设置所有的 pass 并声明要执行的 pass 和每个 pass 中要使用的资源

这个过程需要用户参与并通过 render graph builder 接口来完成

## completion

判断上述这些 pass 有没有资源输出。如果没有输出，则可以选择性剔除该 pass。

此过程还会计算资源的生命周期，让 render graph 系统以有效的方式创建和释放资源，并在异步计算管线上执行 pass 时，根据渲染状态计算正确的同步点。而这个过程不需要我们用户的参与 render graph 系统会根据第一步的 pass 设置来自动处理。

## execution

按照生命周期顺序来执行所有未被裁剪的 pass，在每个 pass 执行前，render graph 系统会创建适当的资源并在执行结束后销毁他们。

# Pass

## RenderGraphPass

- 通过 AddRenderPass 添加
- 过时接口，有很多与现代图形管线功能冲突的限制（比如 native render pass）

## UnsafeRenderGraphPass

- 通过 AddUnsafePass 添加
- 可以做一些光栅化与 GPU 计算之外的操作，并可以访问完整的 CommandBufferAPI, 但使用有一些限制，某些行为性能可能次优，不够高效

## RasterRenderGraphPass

- 通过 AddRasterRenderPass 添加
- 处理一些与光栅化渲染相关的指令与行为

## ComputeRenderGraphPass

- 通过 AddComputePass 添加
- 处理 GPU 计算相关的指令与行为

# RTHandle System

## 什么是 RTHandle System

自定义渲染管线 SRP 中管理 render texture 的一个重要系统

RT handle 是 unity 引擎中 render texture API 之上的一个抽象层，用来自动处理渲染纹理的管理

- 可以不再仅使用固定分辨率来分配渲染纹理
- 可以使用给定分辨率下全局相关的比例来声明渲染纹理
- 只需要在渲染管线中分配一次纹理就可以将其重复用于不同的相机

也就是说，渲染纹理的实际分辨率不一定与当前窗口相同，它可以更大。遍历渲染相机前，声明最大引用大小来实现的。SRP 内部会自动跟踪你声明的最大引用尺寸和全局相关比例来使用它作为渲染纹理的实际大小。

每当声明新的渲染纹理引用尺寸时，会检查它是否大于当前记录的最大引用尺寸。如果大于，该系统会在内部重新分配所有渲染纹理的尺寸以适配新的引用大小并将系统内的最大引用尺寸替换成新设置的尺寸。

不过这里有个例外，RTHandle System 也提供分配固定大小的渲染纹理接口，在这种情况下，使用固定大小接口分配的渲染纹理永远不会被重新分配。

# Native Render Pass

在 SRP 下，这个功能可以通过 RenderGraph.nativeRenderPassesEnabled 开启。

但要注意，这个功能只支持特定的图形 API 和平台。所以需要单独创建一个 util 用来排除不支持的平台。

## 不开启 Native Render Pass 的渲染情况

虽然我们没有手动设置 destential attachment，但在 metal 图形 API 下，还是会默认创建了针对于 deep 和 stantial 的 attachment RT，并且被标记成 store

此外还会发现一个 targetAA 的 RT，尽管我没有开启 color buffer 的 MSAA，并且我们会看到这些渲染资源的 store action 都被标记成了 store，所以这些我们没有使用到的渲染资源会造成带宽部分的冗余开销

## 开启 Native Render Pass 的渲染情况

可以看到冗余的 target color aaRT 与 metal 默认创建的 deep and stantial RT 依然存在，只不过 action 被标记成了 don't care，所以不会造成带宽影响

## 手动管理 deep RT

虽然开启 Native Render Pass 后，metal 会帮我们管理默认创建的 deep and stantial RT，但我们自己管理才更好，这样无论是开不开器都可以控制这部分带宽。为此我在创建 back buffer color RT 的同时，又增加了一个 bike color depth RT，代码上添加的方式与 backbuffer color RT 类似。资源导入参数与 RT info 也尽量复用 blackbuffer color rt

## targetAART

Debug.Log("QualitySettings.antiAliasing : " + QualitySettings.antiAliasing);  
Debug.Log("QualitySettings.antiAliasing : " + Screen.msaaSamples);

你会发现默认情况下 depth buffer 是开启 msaa 的。  
而我们创建的是不开启 msaa 的

如果要关闭这部分 RT，需要在创建 LiteRenderPipeline 之前设置 mass 为关闭，即

QualitySettings.antiAliasing = 1 或者 Screen.SetMSAASamples(1)

# 材质属性封装

我们现在是对透明、不透明、截断三种材质，分别做了三种 shader，而一般做法是用材质属性封装，在切换时生成对应 shader 变体。也就是 Uber shader

# 自定义 Unlit Shader GUI

# 自定义 RenderPipeline Assets Editor 实现 SrpBatcher 功能配置

一般来说，我们为自定义管线定制一些引擎支持的渲染功能需要读取或修改引擎的 graphics settings 或其他 project setting 的设置。

那么关于这部分的配置设置，最好是整合到自定义渲染管线 Asset 文件中。

这样一方面可以将引擎渲染相关的一些功能设置统一到 Asset 中，避免管线配置过于分散，不利于统一管理。  
另一方面，我们可以定义一些渲染管线的特殊属性设置，这就需要我们为自己的渲染管线资源定制编辑器。

## RenderPipeline Assets 编辑器的实现

首先需要在 render pipeline Asset 中定义我们需要设置的属性。

增加编辑器代码

LiteRPAssetEditor ： 用于处理编辑器框架

LiteRPAssetGUIHelper ： 用于做 UI 绘制的辅助方法

SerializedLiteRPAssetProperties : 定义编辑器层与 run time 层定义的属性对应的 serialized property 并封装了序列化对象的更新与应用

# 新功能的四部分工作

自定义管线添加渲染新功能的四部分工作
1. 定义渲染属性数据、帧渲染数据
2. 编写渲染属性数据对应的编辑器
3. 编写 RenderGraph Pass
4. 编写 Shader 中对应 GPU 渲染的 Pass

# 主光源阴影

# 小知识

## 为什么 URP 管线下，天空盒渲染要在不透明物体和透明物体之间

在 unity 中默认的 z test 函数为 less equal，也就是只有小于等于当前像素深度的像素才会通过深度检测被绘制出来。

unity 中不透明物体的绘制顺序是从前向后绘制的并且读写深度，所以后绘制的不透明物体深度值大于当前像素深度值的像素都通不过深度检测，所以不会被绘制。而 SKYBOX 绘制是读深度并写入最大深度，那么此时屏幕上已经被不透明物体占据的像素深度检测都不会通过，所以 sky box 绘制的像素是那些没有被不透明物体占据的像素。

接下来的透明物体的绘制顺序改为由后向前绘制，并读取深度，但不会写入深度。那么所有被不透明物体遮挡的透明物体的像素通不过深度检测所以不被绘制，而深度小于不透明物体深度的像素会被重复绘制，这也使得透明物体的绘制会造成更多的 overdraw。

因此将天空盒放在不透明与透明物体之间绘制带来的像素 overdraw 最小。

当然这是默认情况，如果我们在 SHADER 中修改了深度检测函数，那就需要我们用户自己去管理渲染顺序了。