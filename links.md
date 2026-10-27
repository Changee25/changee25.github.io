---
layout: page
title: 友链
permalink: /links/
---

朋友们的博客都放在这里

<div class="friends">
{% for f in site.data.friends %}
  <a class="friend-card" href="{{ f.url }}" target="_blank" rel="noopener">
    <span class="friend-name">{{ f.name }}</span>
    <span class="friend-desc">{{ f.desc }}</span>
    <span class="friend-url">{{ f.url | remove: "https://" | remove: "http://" }}</span>
  </a>
{% endfor %}
</div>
