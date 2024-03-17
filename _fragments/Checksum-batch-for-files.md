---
layout: fragment
title: check the hash of files in batch both in linux and windows
tags: [devops]
description: debug
keywords: devops, Android
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![check_sum](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/check_sum.png)

# 一键批量校验文件完整性（Win+Linux脚本）

> 在Windows和Linux都有专门计算文件hash的命令，但格式都类似于[command] [file] [algorithm]，然后输出长串数字。一是无法直接比较文件出结果，二是比较大量文件时，人工对比异常繁琐。本文就是解决此难题。



## 需求

- 多个软件固件（比如image、OTA包、差分包、定制包）由Jenkins编译产生，存放在Linux服务器上，需要将所有固件发布给测试、市场、运营等相关同事。由于公司服务器在境外，网络会偶尔丢包，偶尔下载的固件会损坏，丢失部分数据，遇到的频率还不低。

- 服务器端每次生成固件，会用脚本生成对比的hash并存在某个文本文件中。提供给相关同事，一般同事用Windows系统，他们不一定很擅长使用cmd或者powershell，为了提高效率，需要提供一个快速校验所有固件完整性的方案，尽可能简单（Windows/Linux一键执行、批量、递归遍历）。

需求是不难，但是要怎么做的**傻瓜/轻便/高效/稳定性强**呢？



## 前言

### 系统命令

计算hash的算法有很多，例如`MD5`、`SHA1`、`SHA256`、`SHA512`等，我们以`sha256`算法举例。

- Windows计算`sha256`

  用Windows传统的cmd.exe：

  ```
  certutil -hashfile xxxx.zip SHA256
  ```

  用Windows近几年推出的powershell.exe：

  ```
  Get-FileHash xxxx.zip -Algorithm SHA256
  ```

  

- Linux计算`sha256`

  用Linux自带命令：

  ```
  sha256sum xxxx.zip
  ```

虽然都可以直接计算出hash值，但大多都是针对单个文件进行设计的，如果文件很多，还得人工校对。



### 尝试方案

#### 免费软件HashTools

[https://www.binaryfortress.com/HashTools/Download/](https://www.binaryfortress.com/HashTools/Download/)

这个是国外开发的Windows exe工具。

![image-20240317162137640](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240317162137640.png)

![image-20240317162003691](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240317162003691.png)

优点是可以批量计算文件的各种算法的hash值；

缺点也很明显，没法批量对比各个文件的hash，而需要手动一个一个点开输入需要对比的hash值。

而且作为商业级应用的软件，最好是要安全可控，所以还是建议工程师自行开发。

#### 方案选择

- python脚本

python有丰富的命令集，实现这个需求应该不难。

但是核心问题是不是所有的工程师都有python环境，总不能带上一个python库吧，而且还要同事、客户需要怎么用python。

- java脚本

java的语法也很方便，实现这个需求应该不难，但每次都要借助java虚拟机运行，也要带上jre，也容易出问题。

>  此外，java和python运行效率都不高。
>
> 

- 一键执行的脚本

Linux有丰富的shell脚本， Windows也有Powershell，对于这个需求，基本也可以实现。

最大的优势是，脚本文件很轻便，执行快速，使用简单。



## 解决方案

废话不多说，直接上方案。



在服务器端，针对每一个固件zip包生成hash：

```sh
find . -name "*.zip" | xargs -I {} sha256sum {} >> zips.sha256
```

发布到用户手里，如果校验呢？



### Linux

- checksum_linux.sh

```shell
#!/bin/bash
echo "Verify checksum of all ZIP files:"
file_arr=$(find $(pwd) -name *.zip) ;
for file in $file_arr
do
	 base_name=$(basename $file)
	 grep $base_name  ./*.sha256   | awk '{print $1}' > .hash
	 source_hash=`cat .hash`
	 target_hash=$(sha256sum $file) 
     if_exist=`echo $target_hash |  grep $source_hash  | wc -l`

	 if [ "$if_exist" != "0" ]; then
	       echo -e "\e[42m $base_name -> same ^_^ \e[0m"
	 else
	       echo -e "\e[41m $base_name -> diff!!! \e[0m"
	 fi
done
rm .hash
```

将该脚本放在整个固件包路径下面的，然后执行：

```shell
./checksum_linux.sh
```

![image-20240317165638504](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240317165638504.png)

这样很显然，显示diff的文件就是不完整。



### Windows

- cheksum_powershell.ps1

```powershell
###### @author: Lucas.D ##############
###### @data  : 2024-03-16   ##########################

$hash_file = Get-Content ".\*.sha256"
$artifacts_hashmap=@{}

foreach ($i in $hash_file)
{
 $pair = $hash_file[$i.ReadCount-1] -split "  ", 2
 $artifacts_hashmap.add($pair[1], $pair[0])
}

write-host "Verify checksum of all ZIP files:"
$find_file_list = Get-ChildItem  .\  -recurse *.zip | %{$_.Name}
for ($i=0; $i -lt $find_file_list.length; $i++)
{
    $file_hash=Get-FileHash (Get-ChildItem  .\  -recurse $find_file_list[$i] | %{$_.FullName}) -Algorithm SHA256
    if ( $file_hash.Hash -eq $artifacts_hashmap[$find_file_list[$i]] ){
        write-host $i":" $find_file_list[$i]"-> same ^_^ " -background green
    } else {
        write-host $i":" $find_file_list[$i]"-> diff!!! " -background red
    }
}
write-host "please tab any key to exit..."
Read-Host

```

将该脚本放在整个固件包路径下面的，选中，右击，点击“选择Powershell运行”

![image-20240317165952401](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240317165952401.png)

这样也很显然，diff的文件是哪个了。

![image-20240317170106710](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240317170106710.png)



## 总结

两个脚本都都是2Kb以内，非常适合携带，并一键快速执行。

此外，如果还有文件没有计入`*.sha256`，可以手动添加：

`[文件名]  [hash]`

此外，还可以考虑将Powershell转化为exe工具。

