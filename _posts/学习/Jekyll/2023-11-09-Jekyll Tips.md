---
layout: post
title:  "Jekyll Tips"
date:   2023-11-09
categories: Jekyll
permalink: /:categories/:title
---

本文记录Jekyll使用中的一些要点，其中内容来自官方文档和网络上的博客，目的在于方便自己写博客和后续的唤起记忆，所以不会有详尽的使用教程，新手还是建议看官方教程，然后用此文查找自己需要的部分。

Jekyll的[官方文档][jekyll-docs]、[GitHub repo][jekyll-gh]、[论坛][jekyll-talk]。  

## 一、配置环境和初步理解

#### 1、Github库
这边不细说，就是你要有github账号然后按照官方教程新建一个github page库，用git软件把它克隆到本地文件夹，现在里面什么东西都没有。

#### 2、Jekyll
这边也不细说，就是你要按照jekyll官方文档给出的友链进行安装。

#### 3、使用Jekyll在库里进行新建
使用命令行执行`jekyll new 指定路径文件夹`，然后在此文件夹下执行`jekyll serve`来运行本地模拟，最后通过命令行里提到的网址在网页上查看效果。  
本地生成文件：
![Jekyll new]({{ site.url }}/assets/JekyllNew.png){:width="512"}  
- `index`、`about`和`404`：index是主页，你会发现其内容就只有一个模板。about是相关页。404就是404。  
- `_posts`：存放着所有的文章，想加文章就在里面创建MD，要注意命名一定是`日期-标题`。
- `_config.yml`：配置文件。  
- `_site`：存放着所有由Jekyll处理生成的Html，可以理解为最终商店，我们不用管这个文件夹，git也应该忽略这个文件夹。
- `Gemfile.lock`和`Gemfile`：这两个文件和依赖有关，我们也不用管。

#### 4、_config.yml
注意，每次修改配置文件之后，要重启Jekyll serve才能看到效果。
- 范围配置默认头信息：
{% highlight ruby %}
defaults:
  -
    scope:
      path: ""
      type: "posts"
    values:
      layout: "post"
      title: "默认标题"
{% endhighlight %}
根目录下所有博客默认布局为`post`，默认标题为`默认标题`。将path改为某一路径，则指定其文件夹内的博客。

## 二、撰写博客
#### 1、文件夹
- `_drafts`文件夹存放着所有的草稿，想看草稿就用jekyll serve --drafts。  
- `site.posts`集合了`_posts`下的全部文章，我们可以这样遍历：
  <ul>
    {% for post in site.posts %}
      <li>
        <a href="{{ post.url }}">{{ post.title }}</a>
      </li>
    {% endfor %}
  </ul>

#### 2、头信息
- `layout`：如果设置的话，会指定使用该模板文件。指定模板文件时候不需要文件扩展名。模板文件必须放在`_layouts`目录下。
- `title`：文章标题，设置以自适应模板。
- `date`：这里的日期会覆盖文章名字中的日期。这样就可以用来保障文章排序的正确。日期的具体格式为YYYY-MM-DD HH:MM:SS +/-TTTT；时，分，秒和时区都是可选的。
- `permalink`：永久链接。设置这个变量，然后变量值就会作为最终的URL地址。  
点开一篇博客，观察浏览器地址，你会发现它是由`categories`加上日期加上标题组成的，这样一旦我们对其中某一项进行了更改，原网址就404了。永久链接就是解决这件事情的，你可以通过`permalink: `自定义其路径，其默认为`permalink: date`即`/:categories/:year/:month/:day/:title.html`，你可以进行增删，甚至直接自定义`permalink: /Jekyll/`。
- `published`：如果你不想在站点生成后展示某篇特定的博文，那么就设置（该博文的）该变量为 false。  


#### 3、文章摘要
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

#### 4、内容
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

## 三、创建页面
默认Jekyll有两个页面，即根目录下的index和about。如需创建新界面，只要新增MD文件即可，头上标记出样式、标题即可。

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
