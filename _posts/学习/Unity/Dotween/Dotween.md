# 大动画序列

```Cpp
DOTween.Sequence()
    .Insert(0, WinPiece1.DOMove(WinPiece1EndPos.position, 0.5f))
    .Insert(0, WinPiece2.DOMove(WinPiece2EndPos.position, 0.5f))
    .Insert(0, WinPiece3.DOMove(WinPiece3EndPos.position, 0.5f))
    .Insert(0, WinPiece4.DOMove(WinPiece4EndPos.position, 0.5f))

    .Insert(0.5f, WinText.DORotate(new(0, WinTextEndRotY, 0), 0.8f, RotateMode.FastBeyond360))
    .Insert(0.5f, WinBg.DORotate(new(0, 0, WinBgEndRotZ), 1.5f))
    .Insert(0.5f, WinBgImg.DOFade(1, 0.167f))

    .Insert(star1StartTime, Star1.DORotate(new(0, 0, StarEndRotZ), 0.35f, RotateMode.FastBeyond360))
            
    .Insert(star1StartTime, Star1.DOScaleX(StarEndScaleX, 0.7f / 4).SetLoops(2, LoopType.Yoyo))
    .Insert(star1StartTime + 0.7f, Star1.DOScaleX(StarEndScaleX, 0.7f / 4))

    .Insert(star2StartTime, Star2.DORotate(new(0, 0, StarEndRotZ), 0.35f, RotateMode.FastBeyond360))
    .Insert(star2StartTime, Star2.DOScaleX(StarEndScaleX, 0.7f / 4).SetLoops(2, LoopType.Yoyo))
    .Insert(star2StartTime + 0.7f, Star2.DOScaleX(StarEndScaleX, 0.7f / 4))

    .SetUpdate(true).Play();
```

# 旋转

# 默认ease

默认是outquad，先快后慢
