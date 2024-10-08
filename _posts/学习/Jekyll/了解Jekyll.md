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

布局是可供网站中的任何页面使用并环绕页面内容的模板。它们存储在名为 _layouts 的目录中。

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

## include