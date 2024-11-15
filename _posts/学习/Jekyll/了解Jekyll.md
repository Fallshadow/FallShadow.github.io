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

## 前言默认值

```yaml
defaults:
  -
    scope:
      path: ""
      type: "pages"
    values:
      layout: "my-site"
  -
    scope:
      path: "projects"
      type: "pages" # previously `page` in Jekyll 2.2.
    values:
      layout: "project" # overrides previous default layout
      author: "Mr. Hyde"
  -
    scope:
      path: "section/*/special-page.html" # 可以使用 * 匹配，有性能问题
    values:
      layout: "specific-layout"
```

此处默认值会被文章明文声明的设置覆盖。

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

## Collections

收集作用是分类，官方示例中使用收集来以 authors 项进行分类。实际使用过程中可以以多种角度进行分类。

### 配置收集

在根目录创建 _config.yml 文件来收集。

```yaml
collections:
  authors:
```

注意 _config.yml 是配置文件，如果想应用更改就要重启 jekyll 服务器。在 cmd 使用 ctrl + c 停止服务器，然后 jekyll serve 重新启动服务器。

### 添加内容

为收集添加内容需要在根目录下创建 _*collection_name* 的文件。在本例中，_authors

在此文件夹下，为每个作者创建一个信息文档。

```markdown
---
short_name: shadow
name: Shadow Fall
position: Creator
---
暗影大人是创造者。

---
short_name: chao
name: Chao Sun
position: Body
---
超是躯壳。
```

### Staff page

site.authors 收集所有的作者。让我们将作者信息显示在 Staff page 员工界面上。

```html

---
layout: default
title: Staff
---

<h1>Staff</h1>

<ul>
  {% for author in site.authors %}
    <li>
      <h2>{{ author.name }}</h2>
      <h3>{{ author.position }}</h3>
      <p>{{ author.content | markdownify }}</p>
    </li>
  {% endfor %}
</ul>

```

### 单独页面

默认情况下，集合不会为其中分类创建页面，即使各个分类分别是一个 md，此时需要修改设置。

```yaml
collections:
  authors:
    output: true
```

这样就可以使用 author.url 链接到输出页面。

```html

---
layout: default
title: Staff
---
<h1>Staff</h1>

<ul>
  {% for author in site.authors %}
    <li>
      <h2><a href="{{ author.url }}">{{ author.name }}</a></h2>
      <h3>{{ author.position }}</h3>
      <p>{{ author.content | markdownify }}</p>
    </li>
  {% endfor %}
</ul>

```

此时页面是一个简单的 md 页面.

### 默认布局

创建 author 布局

```html
---
layout: default
---
<h1>{{ page.name }}</h1>
<h2>{{ page.position }}</h2>

{{ content }}
```

正常操作我们需要更改 author.md 本身的布局。这里我们使用配置默认完成这件事。


```yaml
defaults:
  - scope:
      path: ""
      type: "authors"
    values:
      layout: "author"
  - scope:
      path: ""
      type: "posts"
    values:
      layout: "post"
  - scope:
      path: ""
    values:
      layout: "default"
```

### 将作者与页面作者关联以输出作者写过的文章

修改 layout author 作者页的输出

```Html
---
layout: default
---
<h1>{{ page.name }}</h1>
<h2>{{ page.position }}</h2>

{{ content }}

<h2>Posts</h2>
<ul>
  {% assign filtered_posts = site.posts | where: 'author', page.short_name %}
  {% for post in filtered_posts %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
```

修改 layout post 让文章可以链接到作者

```Html
---
layout: default
---
<h1>{{ page.title }}</h1>

<p>
  {{ page.date | date_to_string }}
  {% assign author = site.authors | where: 'short_name', page.author | first %}
  {% if author %}
    - <a href="{{ author.url }}">{{ author.name }}</a>
  {% endif %}
</p>

{{ content }}
```

### 类似的，我们可以新创建一个 series 分类

配置中创建收集项分类名，创建分类文件夹，添加各种分类页面并设置属性，将博客分门别类添加分类属性，为分页创建通用布局（比如收集所有属于此分类的页面），回到设置项配置默认布局，创建导航页面，修改导航数据。

## gemfile

创建一个 Gemfile。这可确保 Jekyll 和其他 Gem 的版本在不同环境中保持一致。

Gemfile.lock，用于锁定当前 Gem 版本以供将来的捆绑包安装。如果您想更新 Gem 版本，可以运行 bundle update。

使用 Gemfile 时，您将运行带有 bundle exec 前缀的 jekyll serve 等命令。所以完整的命令是：

```cmd
bundle exec jekyll serve
```

这会限制您的 Ruby 环境仅使用在 Gemfile 中设置的 Gem。

## Plugins Deployment

略

## 命令行

```cmd
jekyll command [argument] [option] [argument_to_option]

jekyll new PATH          - 在指定路径处创建一个具有基于 Gem 的默认主题的新 Jekyll 站点。将根据需要创建目录。
jekyll new PATH --blank  - 在指定路径处创建新的空白 Jekyll 站点基架。
jekyll build 或 jekyll b - 将网站一次性构建为 ./_site（默认情况下）。
jekyll serve 或 jekyll s - 每当源文件发生更改并在本地提供时，都会构建您的站点。
jekyll clean             - 删除所有生成的文件：目标文件夹、元数据文件、Sass 和 Jekyll 缓存。
jekyll help              - 显示给定子命令的帮助（可选），例如 jekyll help build。
jekyll new-theme         - 创建新的 Jekyll 主题基架。
jekyll doctor            - 输出任何弃用或配置问题。
```



## Environments 环境

通过指定环境变量，可以使某些内容仅在特定环境中可用。

```html
JEKYLL_ENV=production jekyll build # 以此方式执行 build 后，下面代码才会执行

{% if jekyll.environment == "production" %}
   {% include disqus.html %}
{% endif %}
```

JEKYLL_ENV 的默认值为 development。因此，如果您在 build 参数中省略 JEKYLL_ENV，则默认值将为 JEKYLL_ENV=development。