---
layout: post
title: Cunit applying in Android System
categories: [linux, android]
description: Cunit是C/C++语言的单元测试框架，常用于Windows和Linux开发中。Android系统中经常有jni、so库、hal service等都是C/C++实现，本文讲解如何将Cunit嵌入Android中，用于测试一些C/C++ api。
keywords: cunit, android
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



# Android系统中使用Cunit测试C/C++接口

> Cunit是C/C++语言的单元测试框架，常用于Windows和Linux开发中。
>
> Android系统中经常有jni、so库、hal service等都是C/C++实现，本文讲解如何将Cunit嵌入Android中，用于测试一些C/C++ api。



## Cunit简介

Cunit是很早的C/C++接口测试框架，官网如下：

https://cunit.sourceforge.net/contact.html

测试模式有4种：

| **模式**  | **介绍**                                                     |
| --------- | ------------------------------------------------------------ |
| Basic     | 最常用的，结果输出到标准输出（stdout）                       |
| Automated | 生成完XML文件之后，然后再将CUnit-List.dtd、CUnit-List.xsl、CUnit-Run.dtd、CUnit-Run.xsl（这几个文件在CUnit的源码包可以找到）和XML文件放到同一级目录，再用IE浏览器打开，就可以看到漂亮的界面了。 |
| Console   | 比较灵活，可以选择只执行其中某一个测试用例。                 |
| Curses    | 跟Console类似，只不过是以Curses窗口的方式展示。              |


| **模式**  | **平台**   | **结果输出方式** | **使用的接口函数**                                           |
| --------- | ---------- | ---------------- | ------------------------------------------------------------ |
| Basic     | 所有       | 标准输出  | #include "CUnit/Basic.h"<br>CU_basic_set_mode(CU_BRM_VERBOSE);<br>CU_basic_run_tests(); |
| Automated | 所有       | xml文件   | #include "CUnit/Automated.h"<br>CU_list_tests_to_file();<br>CU_automated_run_tests(); |
| Console   | 所有       | 交互式控制台| #include "CUnit/Console.h"<br>CU_console_run_tests();            |
| Curses    | Linux/Unix| 交互式curses窗口| #include "CUnit/CUCurses.h"<br>CU_curses_run_tests();            |

这4种模式最终的测试效果如下：
https://cunit.sourceforge.net/screenshots.html

| **模式**  | **测试结果呈现**                                       |
| --------- | -----------------------------------------------------|
| Basic     | https://cunit.sourceforge.net/ss_basic.html          |
| Automated | https://cunit.sourceforge.net/ss_automated.html      |
| Console   | https://cunit.sourceforge.net/ss_console.html        |
| Curses    | https://cunit.sourceforge.net/ss_curses.html         |



具体的使用文档可以参考如下：

https://cunit.sourceforge.net/documentation.html

https://cunit.sourceforge.net/doc/index.html



中文文档：

https://blog.csdn.net/iuices/article/details/115280751



测试demo：

https://cunit.sourceforge.net/example.html

源码下载：

https://sourceforge.net/projects/cunit/

交流论坛：

https://sourceforge.net/p/cunit/discussion/



## 应用于Android



### 编写mk/bp文件



### 如何使用



### 修改Cunit框架



## 源码分享







