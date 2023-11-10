---
layout: post
title:  "Jekyll Tips"
date:   2023-11-09 
categories: jekyll update
---

Jekyll的[官方文档][jekyll-docs]、[GitHub repo][jekyll-gh]、[论坛][jekyll-talk]。  

## 撰写博客
#### 1、文件夹
- `_posts`文件夹存放着所有的文章，想加文章就在里面创建MD，要注意命名一定是`日期-标题`。  
- `_drafts`文件夹存放着所有的草稿，想看草稿就用jekyll serve --drafts。  
- `site.posts`集合了`_posts`下的全部文章，我们可以这样遍历：
  <ul>
    {% for post in site.posts %}
      <li>
        <a href="{{ post.url }}">{{ post.title }}</a>
      </li>
    {% endfor %}
  </ul>

#### 2、文章摘要
- 对于_posts里的每一篇文章，Jekyll会自动提取第一段文字或者说第一次出现`excerpt_separator`的地方作为此文章的摘要。  
- 你可以在文章头使用`excerpt_separator:<!--more-->`来进行替换，或者在`_config.yml`中全局声明`excerpt_separator`，将`excerpt_separator`设置为`""`可以完全禁用摘要。  
- 有摘要的所有文章输出（过滤器中删除了摘要的段落换行）
  <ul>
    {% for post in site.posts %}
      <li>
        <a href="{{ post.url }}">{{ post.title }}</a>  {{ post.excerpt | remove: '<p>' | remove: '</p>' }}
      </li>
    {% endfor %}
  </ul>

#### 3、内容
- 引用图片，可以通过属性控制居中和大小等：
{:refdef: style="text-align: center;"}
![生离死别]({{ site.url }}/assets/生离死别.png){:width="512"}  
{: refdef}
- 下载PDF：[下载 测试PDF]({{ site.url }}/assets/测试用.pdf)。  
- 链接到其他博文：[第一篇博客]({% post_url 2023-11-09-MyFirstBlogTry %})  [Jekyll文件夹下的Jekyll Tips]({% post_url 2023-11-09-Jekyll Tips %})
- 高亮代码：
{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}
- 高亮带行数代码：
{% highlight ruby linenos %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

## 创建页面
默认Jekyll有两个页面，即根目录下的index和about。如需创建新界面，只要新增MD文件即可，头上标记出样式、标题、和永久链接即可。

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
