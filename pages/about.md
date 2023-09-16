---
layout: page
title: About
description: 外企摸鱼程序员
keywords: Lucas.D, dengtonglong
comments: true
menu: 关于
permalink: /about/
---

水硕毕业，从事Android系统开发6年，曾就职于某知名手机公司，现工作于某垂直领域头部小外企。

上架干货，记录碎片，各位大佬多指点！

v1.0.1


## 联系

<ul>
{% for website in site.data.social %}
<li>{{website.sitename }}：<a href="{{ website.url }}" target="_blank">@{{ website.name }}</a></li>
{% endfor %}
{% if site.url contains 'mazhuang.org' %}
<li>
微信公众号：<br />
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
