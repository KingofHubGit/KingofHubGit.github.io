---
layout: post
title: Deep Learning of Repo
categories: Android
description: repo history, creation and usage
keywords: repo, git, windows repo, python
---

Repo主要产生于AOSP开发，因为Android源码庞大，将各仓库用git管理，repo再管理他们。

------



## 基本介绍

### 描述

- Repo主要产生于AOSP开发，因为Android源码庞大，将各仓库用git管理，repo再管理他们。

- Repo通过manifest配置文件来管理众多的源码git仓库，且支持使用repo的众多命令集来操作各个仓库源码。

- Repo使用Python语言开发的，2和3均支持，所以需要有python环境。

- Repo的基本框架，可以简单粗暴地理解为，repo解析manifest文件，然后将整个项目的信息，以python类的形式，加载到了系统内存/系统环境。

- 基于配置好的repo环境，repo相关的命令操作，相当于开启子线程执行对应的git操作，每个repo命令都可以在.repo/repo/subcmds下面找到对应的python子脚本。

  ```shell
  $ ls
  abandon.py      diffmanifests.py  grep.py      init.py      prune.py       smartsync.py  sync.py
  branches.py     diff.py           help.py      list.py      __pycache__    stage.py      upload.py
  checkout.py     download.py       info.py      manifest.py  rebase.py      start.py      version.py
  cherry_pick.py  forall.py         __init__.py  overview.py  selfupdate.py  status.py
  ```

  ![image-20230927172833503](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20230927172833503.png)

  如果需要，你可以执行定制你的repo命令。

- 关于源码解析，详细可参考文档：

https://blog.csdn.net/stoic163/article/details/78790349



### 组成

- Repo脚本： python脚本本身
- Repo仓库：管理python代码的仓库
- Manifest仓库： 管理repo项目的清单文件仓库
- AOSP子项目仓库：各个子项目的仓库

![image-20230926160910880](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20230926160910880.png)



## Windows版本

正常情况下，建议使用Linux环境下使用repo。

但是如果要在Windows下使用，也不是不可以，但是非常不稳定，容易出问题。

官方文档可参考：.repo/repo/docs/windows.md

```
# References：
* https://github.com/git-for-windows/git/wiki/Symbolic-Links
* https://blogs.windows.com/windowsdeveloper/2016/12/02/symlinks-windows-10/
```



### 环境配置

- 安装比较新的Git for Windows

- 安装Python 3， 不要2版本

- 配置环境变量，Add以下到Path

  ```
  C:\Program Files\Git\cmd
  C:\Program Files\Git\bin
  C:\Program Files\Git\usr\bin
  C:\Python36\
  C:\Python36\Scripts\
  C:\Users\[用户名]\bin\
  ```

   ![image-20230926231500225](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20230926231500225.png)

  

- 确认是python3

![image-20230926231653693](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20230926231653693.png)

### repo配置

```
mkdir ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+rx ~/bin/repo

cd [projects]
mkdir -p .repo
cd .repo
git clone git@github.com:KingofHubGit/git-repo.git
mv git-repo repo
cd ..
repo  init  -u  git@xxxx.com:lucasd-labs/manifest.git   -b main   --repo-url=git@github.com:KingofHubGit/git-repo.git --worktree
```

--worktree 参数要加，不加的话会出现 **error.GitError: Cannot initialize work tree for manifests** 错误



最终使用成功init了，sync等操作也正常。

![image-20230926230834983](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20230926230834983.png)



## URL设置

### 手动

通过环境变量修改repo仓库地址和分支：

```
REPO_URL = 'https://xxx.xxx.net/android-common-utils/git-repo.git'
REPO_REV = 'stable'
```

可以将自己定制的repo，传到github，然后每次使用自己的repo，但这个地方记得改：

![image-20230926163422333](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20230926163422333.png)



### 自动

```shell
repo --trace init -u [manifest_git_path] -m [manifest_file_name] -b [branch_name] --repo-url=[repo_url] --no-repo-verify

--trace:查看repo背后的具体操作。
-u: 指定Manifest库的Git访问路径。
-m: 指定要使用的Manifest文件。
-b: 指定要使用Manifest仓库中的某个特定分支。
–repo-url: 指定要检查repo是否有更新的远端repoGit库的访问路径。
–no-repo-verify: 指定不检查repo库是否需要更新。
```



google官网最新的，需要fq：

```
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
sudo chmod a+x ~/bin/repo
```



如果没有工具，

- 可以尝试国内一些源，比如

  ```shell
  --repo-url=https://gerrit-googlesource.lug.ustc.edu.cn/git-repo
  ```

- 尝试github上现成的，比如

  ```shell
  --repo-url=git@github.com:KingofHubGit/git-repo.git
  ```

注意是用https还是ssh的方式，格式稍有不同。




## Manifest配置

官方的manifest配置可以参考.repo/repo/docs/manifest-format.txt

```
https://github.com/GerritCodeReview/git-repo/blob/main/docs/manifest-format.md
```



### 中文版说明文档

#### Element manifest
- manifest：文件的根元素。

#### Element notice
- 完成时向用户显示的任意文本repo sync。内容只是通过它存在于清单中。

#### Element remote
- 属性name：此清单文件唯一的短名称。此处指定的名称用作每个项目的 .git/config 中的远程名称，因此自动可用于git fetch、git remote和git pull等命令git push。
- 属性alias：别名（如果指定）用于覆盖name以在每个项目的 .git/config 中设置为远程名称。它的值可以重复，而属性name在清单文件中必须是唯一的。这有助于每个项目能够具有相同的远程名称，该名称实际上指向不同的远程 url。
- 属性fetch：使用此远程的所有项目的 Git URL 前缀。每个项目的名称都附加到此前缀以形成用于克隆项目的实际 URL。
- 属性pushurl：使用此远程的所有项目的 Git“推送”URL 前缀。每个项目的名称都附加到此前缀，以形成用于“git push”项目的实际 URL。这个属性是可选的；如果未指定，则“git push”将使用与属性相同的 URL fetch。
- 属性review：上传到的 Gerrit 服务器的主机名repo upload。这个属性是可选的；如果未指定，repo upload则将不起作用。
- 属性revision：Git 分支的名称（例如main或refs/heads/main）。具有自己版本的遥控器将覆盖默认版本。

#### Element default
- 属性remote：先前定义的远程元素的名称。缺少自己的远程属性的项目元素将使用此远程。
- 属性revision：Git 分支的名称（例如main或refs/heads/main）。缺少自己的修订属性的项目元素将使用此修订。
- 属性dest-branch：Git 分支的名称（例如main）。未设置自己的项目元素dest-branch将继承此值。如果未设置此值，项目将revision默认使用。
- 属性upstream：可以在其中找到 sha1 的 Git 引用的名称。在 -c 模式下同步修订锁定清单时使用，以避免必须同步整个引用空间。未设置自己的项目元素upstream将继承此值。
- 属性sync-j：同步时要使用的并行作业数。
- 属性sync-c：设置为 true 以仅同步给定的 Git 分支（在revision属性中指定）而不是整个引用空间。缺少自己的 sync-c 元素的项目元素将使用此值。
- 属性sync-s：设置为 true 也同步子项目。
- 属性sync-tags：设置为 false 以仅同步给定的 Git 分支（在属性中指定revision）而不是其他 ref 标记。

#### Element manifest-server
最多可以指定一个清单服务器。url 属性用于指定清单服务器的 URL，它是一个 XML RPC 服务。



清单服务器应实现以下 RPC 方法：
GetApprovedManifest(branch, target)
返回一个清单，其中每个项目都与当前分支和目标的已知良好修订挂钩。当给出 --smart-sync 选项时，repo sync 使用它。

要使用的目标由环境变量 TARGET_PRODUCT 和 TARGET_BUILD_VARIANT 定义。这些变量用于创建 $TARGET_PRODUCT-$TARGET_BUILD_VARIANT 形式的字符串，例如 passion-userdebug。如果这些变量之一或两者都不存在，程序将调用不带目标参数的 GetApprovedManifest，清单服务器应选择一个合理的默认目标。
GetManifest(tag)



返回一个清单，其中每个项目都与指定标记处的修订挂钩。当给出 --smart-tag 选项时，repo sync 使用它。

#### Element submanifest
- 属性name：此子清单的唯一名称（在当前（子）清单中）。它作为revision下面的默认值。相同的名称可用于具有不同父（子）清单的子清单。

- 属性remote：先前定义的远程元素的名称。如果未提供，则使用默认元素给出的远程。

- 属性project：清单项目名称。项目的名称附加到其远程的获取 URL 以生成实际的 URL 来配置 Git 远程。URL 的格式如下：
  
  ```
  ${remote_fetch}/${project_name}.git
  ```
  
  其中
  
   ${remote_fetch} 是远程的 fetch 属性，
  
  ${project_name} 是项目的名称属性。
  
  
  
  总是附加后缀“.git”，因为 repo 假定上游是一个裸 Git 存储库的森林。如果项目有父元素，其名称将以父元素为前缀。
  
  如果 Gerrit 用于代码审查，项目名称必须与 Gerrit 知道的名称相匹配。
  
  project不能为空，不能是绝对路径或使用“.” 或“..”路径组件。它总是相对于遥控器的获取设置进行解释，因此
  
  如果需要不同的基本路径，请使用所需的新设置声明一个不同的遥控器。
  
  如果未提供，将使用此清单的远程和项目：remote无法提供。
  
  来自子清单的项目及其子清单被添加到 submanifest::path:<path_prefix> 组。
  
- 属性manifest-name：清单项目中的清单文件名。如果未提供，default.xml则使用。

- 属性revision：Git 分支的名称（例如“main”或“refs/heads/main”）、标签（例如“refs/tags/stable”）或提交哈希。如果未提供，name则使用。

- 属性path：相对于 repo 客户端顶级目录的可选路径，子清单 repo 客户端顶级目录应放置在该目录中。如果未提供，revision则使用。path可能不是绝对路径或使用“.” 或“..”路径组件。

- 属性groups：包含的子清单中的所有项目所属的附加组的列表。这会追加和递归，这意味着子清单中的所有项目都带有所有父子清单组。与 的相应元素相同的语法project。

- 属性default-groups：如果在初始化时未指定参数，则要同步的清单组列表--groups=。当该列表为空时，使用此列表而不是“默认”作为要同步的组列表。

#### Element project
可以指定一个或多个项目元素。每个元素都描述了一个要克隆到 repo 客户端工作区中的 Git 存储库。您可以通过创建嵌套项目来指定 Git-submodules。

Git 子模块将被自动识别并继承其父模块的属性，但这些模块可能会被明确指定的项目元素覆盖。

- 属性name：此项目的唯一名称。项目的名称附加到其远程的获取 URL 以生成实际的 URL 来配置 Git 远程。URL 的格式如下：
  
  ```
  ${remote_fetch}/${project_name}.git
  ```
  
  其中 ${remote_fetch} 是远程的 fetch 属性，${project_name} 是项目的名称属性。
  
  总是附加后缀“.git”，因为 repo 假定上游是一个裸 Git 存储库的森林。如果项目有父元素，其名称将以父元素为前缀。
  
  如果 Gerrit 用于代码审查，项目名称必须与 Gerrit 知道的名称相匹配。
  
  “名称”不能为空，也不能是绝对路径或使用“.”。
  
  或“..”路径组件。
  
  它总是相对于遥控器的获取设置进行解释，因此如果需要不同的基本路径，请使用所需的新设置声明一个不同的遥控器。
  
  不对Local Manifests强制执行这些限制。
  
- 属性path：相对于 repo 客户端顶层目录的可选路径，该项目的 Git 工作目录应放置在该目录中。
  
  如果未提供，则使用项目“名称”。如果项目有父元素，其路径将以父元素为前缀。
  
  “路径”可能不是绝对路径或使用“.” 或“..”路径组件。
  
  不对Local Manifests强制执行这些限制。
  如果您想将文件放入结帐的根目录（例如 README 或 Makefile 或其他构建脚本），请改用 copyfile或linkfile元素。
  
- 属性remote：先前定义的远程元素的名称。如果未提供，则使用默认元素给出的远程。

- 属性revision：清单要为此项目跟踪的 Git 分支的名称。名称可以相对于 refs/heads（例如“main”）或绝对的（例如“refs/heads/main”）。标签和/或显式 SHA-1 在理论上应该有效，但尚未经过广泛测试。如果未提供，则使用远程元素给出的修订版（如果适用），否则使用默认元素。

- 属性dest-branch：Git 分支的名称（例如main）。使用时repo upload，更改将提交到该分支进行代码审查。如果在此处和默认元素中均未指定，revision则使用。

- 属性groups：该项目所属的组列表，以空格或逗号分隔。所有项目都属于“all”组，每个项目自动属于一组名称：name和路径：path。例如<project name="monkeys" path="barrel-of"/>，该项目定义隐含在以下清单组中：default、name:monkeys 和 path:barrel-of。如果你将一个项目放在“notdefault”组中，它不会被 repo 自动下载。如果项目有父元素，则name和path此处是前缀元素。

- 属性sync-c：设置为 true 以仅同步给定的 Git 分支（在revision属性中指定）而不是整个引用空间。

- 属性sync-s：设置为 true 也同步子项目。

- 属性upstream：可以在其中找到 sha1 的 Git 引用的名称。在 -c 模式下同步修订锁定清单时使用，以避免必须同步整个引用空间。

- 属性clone-depth：设置获取此项目时要使用的深度。如果指定，此值将覆盖在命令行上使用 --depth 选项提供给 repo init 的任何值。

- 属性force-path：设置为 true 以强制此项目根据其path属性（如果提供）而不是name属性创建本地镜像存储库。此属性仅适用于本地镜像同步，在客户端工作目录中同步项目时将被忽略。

#### Element extend-project
修改命名项目的属性。 此元素在本地清单文件中最有用，可在不完全替换现有项目定义的情况下修改现有项目的属性。这使得本地清单对原始清单的更改更加健壮。

- 属性path：如果指定，则将更改限制为在指定路径签出的项目，而不是具有给定名称的所有项目。
- 属性dest-path：如果指定，则为相对于 repo 客户端顶层目录的路径，该目录应放置此项目的 Git 工作目录。这用于通过覆盖现有path设置来移动结帐中的项目。
- 属性groups：此项目所属的其他组的列表。与 的相应元素相同的语法project。
- 属性revision：如果指定，将覆盖原始项目的修订版。与 的相应元素相同的语法project。
- 属性remote：如果指定，则覆盖原始项目的远程。与 的相应元素相同的语法project。
- 属性dest-branch：如果指定，将覆盖原始项目的目标分支。与 的相应元素相同的语法project。
- 属性upstream：如果指定，则覆盖原始项目的上游。与 的相应元素相同的语法project。

#### Element annotation
可以将零个或多个注释元素指定为项目或远程元素的子元素。每个元素描述一个名称-值对。对于项目，此名称-值对将在“forall”命令期间导出到每个项目的环境中，前缀为```REPO__```

此外，还有一个可选属性“keep”，它接受不区分大小写的值“true”（默认）或“false”。此属性确定在使用 manifest 子命令导出时是否保留注释。



#### Element copyfile

可以将零个或多个 copyfile 元素指定为项目元素的子元素。

每个元素描述一对 src-dest 文件；

“src”文件将在repo sync命令期间被复制到“dest”位置。
“src”是相对于项目的，

“dest”是相对于树的顶部的。

不允许从项目外部的路径复制或复制到 repo 客户端外部的路径。
“src”和“dest”必须是文件。目录或符号链接是不允许的。中间路径也不能是符号链接。
如果缺少，将自动创建“dest”的父目录。



#### Element linkfile

它就像 copyfile 一样，与 copyfile 同时运行，但它不是复制而是创建一个符号链接。

符号链接在“dest”（相对于树的顶部）创建，并指向“src”指定的路径，这是项目中的路径。

如果缺少，将自动创建“dest”的父目录。

符号链接目标可以是文件或目录，但它不能指向 repo 客户端之外。

#### Element remove-project
从内部清单表中删除命名项目，可能允许同一清单文件中的后续项目元素用不同的源替换项目。

此元素在本地清单文件中最有用，用户可以在其中删除项目，并可能用自己的定义替换它。

- 属性optional：设置为 true 以忽略没有匹配project元素的 remove-project 元素。

#### Element repo-hooks
一次只能指定一个 repo-hooks 元素。

- 属性in-project：定义repo-hooks 的项目。该值必须与先前定义的元素的name属性（而不是属性path）相匹配project。
- 属性enabled-list：要使用的repo-hooks 列表，以空格或逗号分隔。
  Element superproject
- 属性name：超级项目的唯一名称。该属性与项目的名称属性含义相同。
- 属性remote：先前定义的远程元素的名称。如果未提供，则使用默认元素给出的远程。
- 属性revision：清单要为此超级项目跟踪的 Git 分支的名称。如果未提供，则使用远程元素给出的修订版（如果适用），否则使用默认元素。

#### Element contactinfo
此元素用于让清单作者自行注册联系信息。它具有“bugurl”作为必需的属性。

这个元素可以重复，任何后面的条目都会破坏前面的条目。这将允许扩展清单的清单作者指定他们自己的联系信息。

- 属性bugurl：针对清单所有者提交错误的 URL。
  Element include
  此元素提供将另一个清单文件包含到原始清单中的功能。正常规则适用于要包含的目标清单 - 它必须是一个可用的清单。
- 属性name：要包含的清单，相对于清单存储库的根指定。“名称”可以不是绝对路径或使用“.” 或“..”路径组件。不对Local Manifests强制执行这些限制。
- 属性groups：包含的清单中的所有项目所属的附加组的列表。这会追加和递归，这意味着包含清单中的所有项目都带有所有父包含组。与 的相应元素相同的语法project。



### 配置详细

#### .repo文件结构

```shell
.repo$ tree -L 1
.
├── copy-link-files.json
├── local_manifests
├── manifests
├── manifests.git
├── manifest.xml
├── project.list
├── project-objects
├── projects
├── repo
└── TRACE_FILE
```




- copy-link-files.json

存在copy link字段会生成



- local_manifests

设置本地清单，只影响本地代码，不受远程清单控制



- manifests

主清单，里面可以有多个xml，根据需要切换哪个，默认情况下是default.xml。



- manifests.git

manifests清单文件的git信息



manifest.xml在老版本中是manifests/default.xml的链接；

在较新版本中是通过include引入：

```
<manifest>
  <include name="default.xml" />
</manifest>
```



- project.list 

所有子仓库的path



- project-objects

所有子仓库的git信息对象



- projects

所有子仓库的git信息实例



- repo

repo python脚本的启动文件



- TRACE_FILE

repo操作相关的trace



#### repo配置案例

所有xml如下：

```
.repo$ find . -name  "*.xml"
./manifests/default.xml
./manifests/delete_projects.xml
./local_manifests/c.xml
./manifest.xml
```



manifest.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
DO NOT EDIT THIS FILE!  It is generated by repo and changes will be discarded.
If you want to use a different manifest, use `repo init -m <file>` instead.

If you want to customize your checkout by overriding manifest settings, use
the local_manifests/ directory instead.

For more information on repo manifests, check out:
https://gerrit.googlesource.com/git-repo/+/HEAD/docs/manifest-format.md
-->
<manifest>
  <include name="default.xml" />
</manifest>
```



default.xml

```xml
<manifest>
	
	<remote 
	name="sub_projects" 
	fetch="ssh://git@xxxx.com/repo_test"
	/>
	
	<default remote="sub_projects" revision="main" sync-j="8"/>
	
	<project name="GitA" path="hello_world/A" revision="main" remote="sub_projects"/>
	<project name="GitB" path="hello_world/B" revision="main" remote="sub_projects">
	    
	    <!--annotation用来配置执行forall的时候，设置环境变量的值，前缀是REPO__-->
	    <!--可以通过执行repo forall -c 'echo $REPO__KEY'，遍历到GitB仓库时,能获取到环境变量值为1.2.3-->
		<annotation name="KEY" value="1.2.3"/>
		
	    <!--每次repo sync 重新拷贝该文件到特定目录，这里是根目录-->
		<copyfile src="README.md" dest="README.md" />
	    <!--每次repo sync 链接该文件到特定目录，这里是根目录的README.md.link文件-->
		<linkfile src="README.md" dest="README.md.link" />
	    
	</project>
	
	<!--可以包含delete_projects.xml文件-->
	<!--<include name="delete_projects.xml"/>-->

</manifest>
```



delete_projects.xml 

```xml
<manifest>
    <!--用于每次repo sync之后删除GitA项目-->
	<remove-project name="GitA" />
</manifest>
```



c.xml（local_manifests）

```xml
<manifest>
	<remote 
	name="sub_projects" 
	fetch="ssh://git@blqsrv819.dl.net/repo_test"
	/>	
	
	<!--只在本地项目中加入GitC项目-->
	<project name="GitC" path="hello_world/C" revision="main" remote="sub_projects">
	</project>
	
	<!--针对已存在的GitA项目，指定分支为lucas-->
	<extend-project name="GitA" revision="lucas" upstream="lucas"/>

</manifest>
```



## 用法

- 基本结构：

```
repo <COMMAND> <OPTIONS>
```



- 查看版本：

```
repo version
-h, –help 显示这个帮助信息后退出.
```



- 自更新：

```
repo selfupdate
–no-repo-verify 不要验证repo源码.
```



- 帮助：

```
repo help [--all|command]
```



- 同步：

```markdown
repo sync [project_name]

-u: 指定Manifest库的Git访问路径。
-m: 指定要使用的Manifest文件。
-b: 指定要使用Manifest仓库中的某个特定分支。
–repo-url: 指定要检查repo是否有更新的远端repoGit库的访问路径。
–no-repo-verify: 指定不检查repo库是否需要更新。
```



- 切换项目起始分支：

```
repo start <newbranchname> [--all|<project>...]
相当于 git checkout -f
```



- 切换项目分支：

```
repo checkout <branchname> [<project>...]
相当于 git checkout
```



- 查询项目分支：

```
repo branches [<project>...]

```



- 查看项目改动点：

```
repo diff [<project>...]

```



- 查看项目改动点：

```
repo stage -i [<project>...]
对git add –interactive命令的封装
```



- 清除项目无用分支（在远程没有的分支名）

```
repo prune [<project>...]
对git branch -d 命令的封装
```



- 删除某个分支：

```
repo abandon <branchname> [<rpoject>...]
对git brance -D命令的封装
```



- 查询项目改动文件：

```
repo status [<project>...]

```



- 和gerrit相关，没有深入研究：

```
repo remote add <remotename> <url> [<project>...]
repo remote rm <remotename> [<project>...]
repo push <remotename> [--all|<project>...]

repo upload [--re --cc] {[<project>]...|--replace <project>}
repo download {project change[/patchset]}
```



- 最有用的命令，循环遍历执行：

```
repo forall [<project>...] -c <command>

-c 后面所带的参数是shell指令，即执行命令和参数。命令是通过 /bin/sh 评估的并且后面的任何参数就如 shell 位置的参数通过。
-p 在shell指令输出之前列出项目名称，即在指定命令的输出前显示项目标题。这是通过绑定管道到命令的stdin，stdout，和 sterr 流，并且用管道输送所有输出量到一个连续的流，显示在一个单一的页面调度会话中。
-v 列出执行shell指令输出的错误信息，即显示命令写到 sterr 的信息。

```

- 例如打印各个仓库的环境变量：

```
repo forall -c "printenv"

REPO_PROJECT 指定项目的名称
REPO_PATH 指定项目在工作区的相对路径
REPO_REMOTE 指定项目远程仓库的名称
REPO_LREV 指定项目最后一次提交服务器仓库对应的哈希值
REPO_RREV 指定项目在克隆时的指定分支，manifest里的revision属性
```



- 使用repo查询，语法比单纯的grep更加易于理解，但是受众不广。

```
repo grep {pattern | -e pattern} [<project>...]

#查找同时包含2和ab在同一行的文件
repo grep -e '2' --and -e 'ab'

#要找一行, 里面有#define, 并且有'MAX_PATH' 或者 'PATH_MAX':
repo grep -e '#define' --and -\( -e MAX_PATH -e PATH_MAX \)

#查找一行, 里面有 'NODE'或'Unexpected', 并且在一个文件中这两个都有的.
repo grep --all-match -e NODE -e Unexpected

```



将所有manifest汇总成最终的文件：

- 合入了local_manifests的内容
- 将缺省的状态也打印出来了，比如具体的commit id

```
repo manifest [-o {-|NAME.xml} [-r]]

-h, –help 显示这个帮助信息后退出
-r, –revision-as-HEAD 把某版次存为当前的HEAD
-o -|NAME.xml, –output-file=-|NAME.xml 把manifest存为NAME.xml
```

比如上述文件中，汇总后的xml如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote fetch="ssh://git@xxxx.com/repo_test" name="sub_projects"/>

  <default remote="sub_projects" revision="main" sync-j="8"/>

  <project dest-branch="main" name="GitA" path="hello_world/A" revision="34cab0481ba0188393509d851ddf70b5e39efd75" upstream="main"/>
  <project dest-branch="main" name="GitB" path="hello_world/B" revision="b4b402becaf32241d8e9bdb6a126df1fd998ed2a" upstream="main">
    <copyfile dest="README.md" src="README.md"/>
    <linkfile dest="README.md.link" src="README.md"/>
    <annotation name="KEY" value="1.2.3"/>
  </project>
  <project dest-branch="main" groups="local::c" name="GitC" path="hello_world/C" revision="d3c0cb59c49c0bd057ccee3a3f82f55ffb4470fc" upstream="main"/>
</manifest>
```



## 场景案例

虽然了解了repo的详细使用方法，还是觉得很空虚。

怎么灵活使用，而方便于开发者呢？进而提升效率。



### 案例一：

假设有一些仓库或者分支，比如密钥，涉密源代码，不能公开给ODM/客户/合作伙伴，虽然他们没有权限拉取，但加入清单，每次提示拉取失败，也是不好的吧。

如果每次拉取项目代码到本地，内部工程师自己用，都需要人工操作一遍，一是繁琐，二是容易出错。

那该怎么办？

- 创建local_manifests目录，添加你需要的特地仓库。甚至可以将local_manifests建立一个独立的git仓库
- 使用extend-project，指定你特定的分支
- 使用remove-project，删除不需要的仓库，比如影响编译
- 使用copyfile，自动化拷贝特定的apk或者其他文件
- 使用linkfile，经常使用的脚本/工具链接到根目录
- ... ...





### 案例二：

当我需要使用repo forall时，在庞大的AOSP源码中，假设我需要单独不对某个或某几个仓库操作，有什么办法呢？

- 方法1（入门）：

```
  repo forall [<project>...] -c <command>
```

  将所需要的仓库列表粘贴到```[<project>...]```

  弊端明显：项目太多太长了，容易出错。

  

- 方法2（进阶）：

  发现.repo下面有project.list文件，用于存储所有项目列表。

  ```
  cp project.list project2.list
  ```

  将忽略的几个仓库删除

  ```
  vim project2.list
  ```

  使用这种方法执行：

  ```
  repo forall `cat .repo/project2.list` -c <command>
  ```

  

- 方法3（高端）：

如果某几个仓库是长期要skip的，利用好annotation元素。



在对应的项目中，加入如下环境变量标识：

  ```
<annotation name="IS_SKIP" value="1"/>
  ```



在forall中写入逻辑：

```
repo forall -c 'if [[$IS_SKIP != 1]]; then <command> ; fi'
```



以上是伪代码，传递基本思想，如果需要使用，自行研究。



