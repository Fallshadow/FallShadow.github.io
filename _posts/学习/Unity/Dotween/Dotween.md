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

    .Append(
            DOTween.To(() => animExp, x => animExp = x, curExp, 0.5f)
                .SetEase(Ease.InOutQuad)
                .OnUpdate(() => {
                    if (SetLevelProgress(preLevel, animExp)) {
                        preLevel++;
                        m_Properties.expLv.text = $"{preLevel}级";
                    }
                })
            )
    .AppendCallback(() => {                
       // 回调 B 的内容  
        })  
    .SetUpdate(true).Play();

    var seq = DOTween.Sequence();  

seq.Append(tweenA)                // A 先执行  
   .Join(tweenE)                  // A 和 E 同步执行  
   .AppendCallback(() => {  
       // 回调 B  
   })  
   .Append(tweenC)                // C 执行  
   .AppendInterval(0.5f)          // 延时 0.5 秒  
   .AppendCallback(() => {  
       // 回调 D  
   });  
```

# 旋转

# 默认 ease

默认是 outquad，先快后慢

# to

```Cpp
        DOTween.To(() => baseValue, x => baseValue = x, evolveValue, 0.5f)
                 .SetEase(Ease.InOutQuad)
                 .OnUpdate(() => {
                     equipValue.text = baseValue.ToString();
                 }).SetDelay(1f);
```