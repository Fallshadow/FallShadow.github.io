```html
<nav>
  <a href="/">Home</a>
  <a href="/about.html">About</a>
</nav>
```

nav 用于定义页面中的导航部分。通常包含一组链接，帮助用户在网站的不同页面之间导航。  
a 标签：表示一个超链接。  
href = ：链接的目标地址。  


```html
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

ul 表示列表的开始和结束。所有的列表项目（li 标签）都应该放在 ul 标签内部。
li 代表列表中的一个项目。在此代码中，li 标签被用来包裹每个作者的详细信息。
p 用于定义段落（paragraph）
