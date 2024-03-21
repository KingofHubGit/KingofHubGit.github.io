---
layout: post
title: compatible for repo2 and repo3
categories: [android, repo]
description: some word here
keywords: android, repo， devops
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![repo_bin](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/repo_bin.png)

[TOC]

# 定制repo（不再切换python和google源）

> 众知，Android/AOSP/ROM系统开发，不可避免地要和repo打交道。但repo并不好用，和python版本相关联、拉取google源、容易受共用服务器影响。本文提出了灵活管理repo的办法，还需简单魔改一下。



## 前言

关于repo最详尽的知识，在这里不再赘述，详情参考本人文章：《深入学习Repo》

使用repo有以下几个痛点：

- python版本不对，会影响使用，需要切换
- 每次使用会默认拉取最新代码，国内没法访问google，然后卡死在这
- repo用apt安装默认在usr/bin/下面，容易被同服务器的操作干扰，而突然失效/出问题

- 有的项目用的是repo2有的项目用的是repo3，每次都要去确认，然后选择用哪个



由于repo分别有python2.7和python3+的版本，在文章下面我们统称为repo2和repo3



## 各用各的repo

repo本质上是一个python代码编译出的linux二进制文件。

如果使用apt来安装repo，将会默认安装在usr/bin/

在linux服务器中，如果有用户更新、替换了repo，甚至切换了python，那可能会影响另一个用户的行为。

所以解决方案是：

```shell
git clone git@xxx.net:/git-repo.git
cd git-repo/
mkdir ~/bin/
cp repo ~/bin/
chmod a+x ~/bin/repo
```

这样就互不干涉，比如用户abc，用的repo就在`/home/abc/bin/repo`下面

并且将这个bin加入环境变量PATH：

```
PATH=~/bin:$PATH
```





由于repo有2和3两个版本，

如果适用python2，我们就命名为repo2；

如果适用python3，我们就命名为repo3；

下面我们会讲解如何解决不同的repo要使用不同的python版本的问题。

```shell
git clone git@xxx.net:/git-repo2.git
cd git-repo2/
mkdir ~/bin/
cp repo ~/bin/repo2
chmod a+x ~/bin/repo2

git clone git@xxx.net:/git-repo3.git
cd git-repo3/
mkdir ~/bin/
cp repo ~/bin/repo3
chmod a+x ~/bin/repo3
```



## 定制repo2/repo3源码

repo每次都会拉取更新最新的repo版本，但是很多内容的更新，并不一定对我们普通工程师有影响。

所以，提出了一个大胆的想法，将repo单独领出来，建一个自己的仓库，而不去goole的源码地址拉取，不然国内老提示无法访问。



以下是本人的仓库

https://github.com/KingofHubGit/git-repo2

https://github.com/KingofHubGit/git-repo3



对于google官方的源码做了以下几处修改：

- 修改每次拉取的源为我自己的github地址：

  ```
  REPO_URL = "git@github.com:KingofHubGit/git-repo3.git"
  ```

-  修改每次拉取的源为我自己的github分支：

  ```
  REPO_REV = "main"
  ```

  由于早期项目都是默认master分支，现在改为main分支了。所以此处要更新。

- 使用repo过程中，发现python脚本不对，我们就会使用以下命令：

  ```
  sudo update-alternatives --config python
  ```

  如果老是切换python版本，这样会影响别人，影响android源码的编译

  所以针对于repo3，将python环境变量改为

  ```
  #!/usr/bin/env python3
  ```

  针对于repo2，将python环境变量改为

  ```
  #!/usr/bin/env python2
  ```

- 虽然github国内可以访问，也经常抽搐，可以改成gitee。

  最根本的方法是直接不要再拉取最新的源码啦！

  默认关闭拉取源码：

  ```python
  group.add_option(
          "--no-repo-verify",
          dest="repo_verify",
          default=False,
          action="store_false",
          help="do not verify repo source code",
      )
      
      
      def check_repo_verify(repo_verify=False, quiet=False):
  ```
  
  




## 自动识别repo2/repo3项目

有了上面的定制化修改，不用再切换python版本啦！

但如果项目A的源码用repo2， 项目B的源码用了repo3，那可咋整啊，每次repo2和repo3要改来改去，最初的repo呢？

针对于这个，这里提出了一个妙招：

可以在`~/.bashrc`下面增加一个repo的函数方法，用于判断识别项目是repo2还是repo3，然后调用对应的repo：

```shell
repo(){
	#echo "$@"
	#确认已经是repo项目了
    if [ -f "./.repo/repo/repo" ]; then
    	#判断是否为repo2
    	is_repo2=`grep 'MIN_PYTHON_VERSION.*2,' ./.repo/repo/repo | wc -l`
    	#echo "is_repo2="$is_repo2
        if [ "$is_repo2" == "1" ];then 
        	echo "repo2 working"
        	#调用~/bin/repo2
    		eval "~/bin/repo2 $@ "
    	else
    		echo "repo3 working"
    		#调用~/bin/repo3
    		eval "~/bin/repo3 $@"
    	fi
    else
        #默认使用~/bin/repo3
    	echo "repo3 working"
    	eval "~/bin/repo3 $@"
    fi
}
```





## 完整解决方案：

- 拉取repo2

```shell
git clone git@github.com:KingofHubGit/git-repo2.git

cd git-repo2/
mkdir ~/bin/
PATH=~/bin:$PATH
cp repo ~/bin/repo2
chmod a+x ~/bin/repo2
```
- 拉取repo3

```shell
git clone git@github.com:KingofHubGit/git-repo3.git

cd git-repo3/
mkdir ~/bin/
PATH=~/bin:$PATH
cp repo ~/bin/repo3
chmod a+x ~/bin/repo3
```

- 将代码块添加到`~/.bashrc`下面

```shell
repo(){
    if [ -f "./.repo/repo/repo" ]; then
    	is_repo2=`grep 'MIN_PYTHON_VERSION.*2,' ./.repo/repo/repo | wc -l`
    	#echo "is_repo2="$is_repo2
        if [ "$is_repo2" == "1" ];then 
        	echo "repo2 working"
    		eval "~/bin/repo2 $@ "
    	else
    		echo "repo3 working"
    		eval "~/bin/repo3 $@"
    	fi
    else
    	echo "repo3 working"
    	eval "~/bin/repo3 $@"
    fi
}
```

- 重新加载环境

```
source ~/.bashrc
```

- 实践出真知：

拉取repo项目，默认使用repo3

![image-20240309183238623](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240309183238623.png)

这里是一个repo2项目：

![image-20240309183547838](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240309183547838.png)

从所未有的干净清爽！



> 注意：如果bash具有repo函数了，理论上优先级高于usr/bin/repo，为了以防万一有干扰，可以尝试将usr/bin/repo重命名为usr/bin/repo_google。



如果这篇文章对你有用的话，麻烦留下你的关注，我将持续亮剑干货！



