---
layout: page
title: 博客分类
permalink: /categories/
---
<div id="archives">
{% for category in site.categories %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ category_name | slugize }}"></div>
    <p></p>

    <h3 class="category-head">{{ category_name }} ({{ site.categories[category_name].size() }})</h3>
    <a name="{{ category_name | slugize }}"></a>
    {% for post in site.categories[category_name] %}
    <article class="archive-item">
      <h4><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h4>
    </article>
    {% endfor  %}
  </div>
{% endfor %}
</div>