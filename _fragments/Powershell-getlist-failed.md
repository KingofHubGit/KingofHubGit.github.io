---
layout: fragment
title: PowerShell get file list failed on occasion
categories: [devops, powershell]
description: some word here
keywords: devops, powershell
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---
![PowerShell-getlist](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/PowerShell-getlist.jpeg)

# PowerShell获取文件列表踩坑

> Powershell强大的函数库，确实很方便，但是也有些坑



## 初步实现

假设有一个路径如下：

![image-20240324110625507](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240324110625507.png)

需要获取`abc_`开头还有`a_`开头的的文件列表， 并打印/处理



按照常规思路，简单写一个：

```powershell
$file_list=Get-ChildItem ./ -Recurse  abc_*

for ($i=0; $i -lt $file_list.Length; $i++)
{
    write-host $i":" $file_list[$i].FullName
}
```

运行结果如下：

```powershell
0: E:\Test\abc_a.txt
1: E:\Test\abc_b.txt
2: E:\Test\abc_d.txt
```



把上面的`abc_*`换成`a_*`

```
$file_list=Get-ChildItem ./ -Recurse  a_*

for ($i=0; $i -lt $file_list.Length; $i++)
{
    write-host $i":" $file_list[$i].FullName
}
```



运行结果如下：

```powershell
0: E:\Test\a_bcd.txt
1: 
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: 
11: 
12: 
13: 
14: 
15: 
```

咋这样了呢？

发现是当文件只有一个的时候，就会翻车！

查看了一下:

```
PS E:\Test> cat .\a_bcd.txt
01234

PS E:\Test> $file_list.Length
16
```

此时的`$file_list.Length`代表的是`$file_list`文件的长度

所以不能用Length，改成Count。



## 优化实现

```powershell
$file_list=Get-ChildItem ./ -Recurse  a_*

for ($i=0; $i -lt $file_list.Count; $i++)
{
    write-host $i":" $file_list[$i].FullName
}
```



运行结果：

```powershell
0: E:\Test\a_bcd.txt
```



## 进阶实现

保险起见，将这个`$file_list`定义为数组。

```powershell
$file_list=@()
$file_list+=Get-ChildItem ./ -Recurse  a_*
for ($i=0; $i -lt $file_list.Count; $i++)
{
    write-host $i":" $file_list[$i].FullName
}
```

用Count还是Length均可。

