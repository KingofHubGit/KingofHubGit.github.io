---
layout: fragment
title: Use alias to kill the Linux process by grep name
tags: [linux]
description: efficiency improvement
keywords: Linux, Ubuntu, CentOS
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---


# Linux alias一键kill进程，脚本调用alias
> 使用Linux的alias功能，实现一键杀进程，并脚本也能调用。



## 提出问题

虽然见过很多如何kill掉某个进程的方法，大体思想就是：

**通过ps获取所有进程，再用grep过滤对应的进程名，然后再用kill命令杀死该进程。**



常年在linux环境下工作的人来说，每次都要走怎么几步，会很繁琐；

就算你把命令存在note里面，每次都要去复制/默写，效率也不够高。



现在提出：

**使用Linux的alias功能，对杀进程功能进行封装。**

> 输入： [process name]或者其过滤字段
>
> 输出： [process name] ---> [pid number]



## 难点分析

现在面临以下几个难点：

- ① 众所周知，ps命令会输出表格信息，如何一次性过滤出pid数字？

  > 需要灵活使用grep和awk

- ② awk命令有单引号，alias自身用单引号定义的，这不就是冲突了嘛。

  如何解决单引号冲突问题？

  > 需要单引号+双引号，结合在一起用

- ③ 如何给alias设计入参？

  > 是可以有的，在alias里面定义func

- ④ 假设脚本中想要调用这个alias，可行吗？

  > 正常bash环境是无法识别的，需要打开识别alias的开关



强调说明一下②，

其中用到的`awk`的参数需要用到单引号。alias也可以使用双引号，但是如果用双引号，其中的内容会被转义解释成具体获得的值，而不是命令本身。

这时可以使用 `'"'"'` 替代单引号。简要解析一下：

- ’ 使用单引号结束第一段；
- " 开启第二段，这里使用双引号；
- ’ 单引号本身；
- " 结束第二段，使用双引号；
- ’ 开启第三段，使用单引号。



## 最终方案

```
alias kill_process_grep_name='
func()
{ 
pid=`ps -ef | grep $1 | grep -v grep | awk '"'"'{print $2}'"'"'`;
if [ -n "$pid" ]; 
then echo $1" ---> "$pid;
kill -9 $pid;
fi ; 
};
func'
```



最终实践：

![image-20231013180306741](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231013180306741.png)

![image-20231013180428010](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231013180428010.png)



## 问题扩展

关于问题④：

假设脚本中想要调用这个alias，该如何设计？

> 用 shopt 开启和关闭 alias 扩展

来看一下shopt的帮助文档：

```shell
$ help shopt 
shopt: shopt [-pqsu] [-o] [optname ...]
    Set and unset shell options.
    
    Change the setting of each shell option OPTNAME.  Without any option
    arguments, list each supplied OPTNAME, or all shell options if no
    OPTNAMEs are given, with an indication of whether or not each is set.
    
    Options:
      -o	restrict OPTNAMEs to those defined for use with `set -o'
      -p	print each shell option with an indication of its status
      -q	suppress output
      -s	enable (set) each OPTNAME
      -u	disable (unset) each OPTNAME
    
    Exit Status:
    Returns success if OPTNAME is enabled; fails if an invalid option is
    given or OPTNAME is disabled.
```

功能大致总结如下：

| Command           | Desc                            |
| ----------------- | ------------------------------- |
| shopt -s opt_name | Enable (set) opt_name           |
| shopt -u opt_name | Disable (unset) opt_name        |
| shopt opt_name    | Show current status of opt_name |

假设某个脚本需要调用，可如下设计：

```shell
#!/bin/bash

echo "start task ..."

shopt -s  expand_aliases
echo "开启alias后，确认状态："
shopt expand_aliases

#杀死bcompare进程
kill_process_grep_name bcompare
```



**如果文章对你有用，麻烦简单评论+点赞！新人需要人气值！**