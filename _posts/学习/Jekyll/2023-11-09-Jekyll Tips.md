---
layout: post
title:  "Jekyll Tips"
date:   2023-11-09 
categories: jekyll update
---

Jekyll的[官方文档][jekyll-docs]、[GitHub repo][jekyll-gh]、[论坛][jekyll-talk]。  

## 文件夹解释
`_posts`文件夹存放着所有的文章，想加文章就在里面创建MD，要注意命名一定是`日期-标题`。  
`_drafts`文件夹存放着所有的草稿，想看草稿就用jekyll serve --drafts。  

引用图片：![生离死别]({{ site.url }}/assets/生离死别.png)  
你可以直接 [下载 测试PDF]({{ site.url }}/assets/测试用.pdf)。  

`site.posts`集合了`_posts`下的全部文章，我们可以这样遍历：
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
## 文章摘要
对于_posts里的每一篇文章，Jekyll会自动提取第一段文字或者说第一次出现`excerpt_separator`的地方作为此文章的摘要。  
你可以在文章头使用`excerpt_separator:<!--more-->`来进行替换，或者在`_config.yml`中全局声明`excerpt_separator`，将`excerpt_separator`设置为`""`可以完全禁用摘要。  
有摘要的文章输出（过滤器中删除了摘要的段落换行）
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>  {{ post.excerpt | remove: '<p>' | remove: '</p>' }}
    </li>
  {% endfor %}
</ul>


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
