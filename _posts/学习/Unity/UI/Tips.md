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