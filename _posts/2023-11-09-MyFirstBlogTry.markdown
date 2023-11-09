---
layout: post
title:  "我的第一篇文章：Jekyll的Tips"
date:   2023-11-09 
categories: jekyll update
---

Jekyll的[官方文档][jekyll-docs]、[GitHub repo][jekyll-gh]、[论坛][jekyll-talk]。

`_posts`文件夹存放着所有的文章，想加文章就在里面创建MD，要注意命名一定是`日期-标题`。  
`_drafts`文件夹存放着所有的草稿，想看草稿就用jekyll serve --drafts。  

引用图片：![生离死别]({{ site.url }}/assets/生离死别.png)  
你可以直接 [下载 测试PDF]({{ site.url }}/assets/测试用.pdf)。  
{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}


[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
