https://jekyllrb.com/

Ruby 是一种纯面向对象的语言，几乎所有的东西都是对象，包括数字、字符串和甚至代码块。

RubyGems 是 Ruby 编程语言的包管理系统。它提供了一种标准化的方式来分发、安装和管理 Ruby 库和应用程序，这些库和应用程序被称为“gem”。

Gemfile 是您的网站使用的 Gem 列表。每个 Jekyll 站点在主文件夹中都有一个 Gemfile。

Bundler 是一个 Gem，用于安装 Gemfile 中的所有 Gem。

## liquid

Liquid 是一种模板语言，用于在 Jekyll 网站生成过程中动态生成内容。Liquid 的设计目的是让用户能够在不编写复杂代码的情况下，轻松地创建动态和可定制的网页内容。

- Objects 对象：将预定义的变量作为页面上的内容输出。使用双大括号。

    ```Cpp
    {{ page.title }}
    ```

- Tags 标签：标签定义模板的逻辑和控制流。对标签使用大括号和百分号：{% 和 %}

    ```Cpp
    {% if page.show_sidebar %}
    <div class="sidebar">
        sidebar content
    </div>
    {% endif %}
    ```
- Filter 过滤器：Filter 可更改 Objects 的输出。它们在输出中使用，并用 |分隔。（这将显示 Hi 而不是 hi。）

    ```Cpp
    {{ "hi" | capitalize }}
    ```

## 前言

Front Matter 前言：是放置在文件开头的两条三虚线之间的 YAML 片段

```Cpp
    ---
    my_number: 5
    ---
```

您可以使用 page 变量在 Liquid 中调用 front matter 变量。例如，要输出上述 my_number 变量的值：

```Cpp
    {{ page.my_number }}
```

如果想使用page.标签处理页面，那么这个页面一定要有前言体，哪怕是空的，也会以默认值处理，但是如果前言体都没有，那就不处理这个页面了（目前的理解是这样，还没试过）。

## 布局

布局是可供网站中的任何页面使用并环绕页面内容的模板。它使用 liquid 读取各个界面下的实际参数内容（比如 Front Matter）并展示。它们存储在根目录下名为 _layouts 的目录中。

可以创建这样的文件 default.html

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>{{ page.title }}</title>
  </head>
  <body>
    {{ content }}
  </body>
</html>
```

在实际使用时

```html
---
layout: default
title: Home
---
<h1>{{ "Hello World!" | downcase }}</h1>
```

## 包含

include，它允许你将 _includes 文件夹中的 html 内容直接插入到 indclude 的 位置。

就比如很多网站都有的，顶部跳转导航，就可以使用 include “顶部导航 HTML” 来实现。当然，可以放在 layout 中，让各个使用了此 layout 的界面，都吃到导航，但也许你想要某个与众不同的界面也有导航，这就需要 include。

让我们创建 _includes/navigation.html

```html
<nav>
  <a href="/">Home</a>
  <a href="/about.html">About</a>
</nav>
```

应用到 _layouts/default.html

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>{{ page.title }}</title>
  </head>
  <body>
    {% include navigation.html %}
    {{ content }}
  </body>
</html>
```

可以使用 page.url 获取当前界面的 url，以此判断导航子链接是不是当前界面，并标红色

```html
<nav>
  <a href="/" {% if page.url == "/" %}style="color: red;"{% endif %}>
    Home
  </a>
  <a href="/about" {% if page.url == "/about" %}style="color: red;"{% endif %}>
    About
  </a>
</nav>
```

## a 标签

```Cpp
<a> 标签是 HTML 中的锚点标签，用于创建超链接。超链接可以将用户从一个页面导航到另一个页面、同一页面的不同部分、下载文件，或者启动电子邮件客户端。

href 是 HTML 中 <a>（锚点）标签的一个属性，代表 "Hypertext Reference"。它用于指定链接目标的 URL（统一资源定位符）。当用户点击链接时，浏览器会导航到由 href 属性指定的地址。
```

## 数据文件

_data 文件夹存放数据文件。

YAML 是 Ruby 生态系统中常见的一种格式。可以使用它来存储一组导航项。

在 _data/navigation.yml 处创建数据文件。

```Cpp
- name: Home
  link: /
- name: About
  link: /about.html
```

如此，便可以使用 site.data.navigation 找到此数据文件。便可以使用迭代输出每个导航，而不是写成堆的代码。

```Cpp
<nav>
  {% for item in site.data.navigation %}
    <a href="{{ item.link }}" {% if page.url == item.link %}style="color: red;"{% endif %}>
      {{ item.name }}
    </a>
  {% endfor %}
</nav>
```

## 资源

assets 文件夹，其下创建 css image js 文件夹。

我们之前在 include 的 navigation 中直接使用红色样式，这并不是一个好做法。

使用标准 CSS 文件进行样式设置。这里我们使用 scss 文件。

创建 assets/css/styles.scss

```Cpp
---
---
@import "main";
```

这句话告诉 Sass 我们已经在根目录下创建好了名为 _sass 的文件夹，并且查找 _sass 下名为 main.scss 的文件。

```scss
.current {
    color: green;
}
```

此时我们再更改 navigation

```html
<nav>
  {% for item in site.data.navigation %}
    <a href="{{ item.link }}"{% if page.url == item.link %} class="current"{% endif %}>
      {{ item.name }}</a>
  {% endfor %}
</nav>
```

但还没完，样式表是跟随 layout 布局的。

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>{{ page.title }}</title>
    <link rel="stylesheet" href="/assets/css/styles.css">
  </head>
  <body>
    {% include navigation.html %}
    {{ content }}
  </body>
</html>
```

总而言之，这个例子在资源文件夹中加入了css样式文件，并且此样式外链到了sass文件夹，设置详细内容，也就是css是一个总目录，真正子项样式都在sass文件夹中。然后样式是可以跟随布局的。

## post

博客被放置在 _posts 文件夹下，且命名必须规范，发布日期，标题，扩展名。

_posts/2018-08-20-bananas.md

### 在 layout 下创建 post 布局

```html
---
layout: default
---
<h1>{{ page.title }}</h1>
<p>{{ page.date | date_to_string }} - {{ page.author }}</p>

{{ content }}
```

此布局继承自 default

### 在根目录下创建 Blog 导航页

```html
---
layout: default
title: Blog
---
<h1>Latest Posts</h1>

<ul>
  {% for post in site.posts %}
    <li>
      <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>
```

site.posts : 所有 post
post.url : 设置为 post 的输出路径
post.title : 从 post 文件名中提取的，可以通过在 front matter 中设置 title 来覆盖
post.excerpt : 默认是内容的第一段

### 主导航数据增加 Blog

```yaml
- name: Home
  link: /
- name: About
  link: /about
- name: Blog
  link: /blog
```


