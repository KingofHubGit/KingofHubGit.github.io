---
layout: page
title: About
description: 外企摸鱼程序员
keywords: Lucas.D, dengtonglong
comments: true
menu: 关于
permalink: /about/
---

一边踉跄出行，一边朝圣光明。
摧而俞坚，历久弥新。


## 联系

<ul>
{% for website in site.data.social %}
<li>{{website.sitename }}：<a href="{{ website.url }}" target="_blank">@{{ website.name }}</a></li>
{% endfor %}
{% if site.url contains 'kingofhubgit' %}
<li>
<img style="height:192px;width:192px;border:1px solid lightgrey;" src="{{ site.url }}/assets/images/qrcode.jpg" alt="Lucas.D" />
</li>
{% endif %}
</ul>


## Skill Keywords

{% for skill in site.data.skills %}
### {{ skill.name }}
<div class="btn-inline">
{% for keyword in skill.keywords %}
<button class="btn btn-outline" type="button">{{ keyword }}</button>
{% endfor %}
</div>
{% endfor %}
