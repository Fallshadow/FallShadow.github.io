## 进度条

制作进度条时，在适应屏幕宽度情况下，更改 pivot 为 (0, 1)，如果进度条是倾斜的，不可以进行简单的 scale 拉伸，这时候需要使用九宫格 + SizeDetal 调节。

你会发现 SizeDetal 在适应拉伸情况下总是 x = 0。这就需要在一开始记录下 rect 的 width，以此为最大值，然后更改 SizeDetal X 来进行调节进度。由于未知原因，这些操作请在 start 里执行

```Cpp

private void Start() {
    maxWidth = processRect.rect.width - 20;
    processRect.sizeDelta = new Vector2(-maxWidth, processRect.sizeDelta.y);
    processRect.DOSizeDelta(new Vector2(0, processRect.sizeDelta.y), processTime);
}

private void Update() {
    if (processText != null) {
        processText.text = $"{(int)(((maxWidth + processRect.sizeDelta.x) / maxWidth) * 100)}%";
    }
}

```

## 适配

因为现在阅读都是从左到右，所以我们的排版都是以宽度为核心缩放，保证宽度百分比不变。在制作时挑选一个需要适配的最小分辨率机型，然后依次来设计和排布 UI。这会导致在其他更大机型上留出更多空间，这也是无法避免的，毕竟我们不想以一个大分辨率机型作为制作分辨率以至于小机型 UI 重叠。

### 按不到

视觉上可以不调节，在程序上调节。

### UI数据

可以把 ui 使用到的数据放在 cache 中，在打开 UI 之前更改这份数据，然后再打开 UI 后，UI 默认就去读取那些数据。

### 