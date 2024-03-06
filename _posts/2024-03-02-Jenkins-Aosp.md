---
layout: post
title: Framework designing of Jenkins-AOSP build system
categories: [android, jenkins, devops]
description: Android系统开发经常需要用到自动化编译系统，用于正式发布/日构建/验证修改点/远程触发等。Jenkins是最常用最广泛的DevOps工具之一。本文重点讲解如何在Jenkins上面部署灵活设计/解耦性强/扩展性强的AOSP编译系统。
keywords: android, jenkins, devops
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



[TOC]



# Jenkins-Android源码编译【架构设计】（适用鸿蒙/自动化/多产品/持续迭代）



> Android系统开发经常需要用到自动化编译系统，用于正式发布/日构建/验证修改点/远程触发等。
>
> Jenkins是最常用最广泛的DevOps工具之一。本文重点讲解如何在Jenkins上面部署灵活设计/解耦性强/扩展性强的AOSP编译系统。





## 通俗介绍Jenkins

Jenkins可以简单地理解为一个Server+Web应用，同时具有Winows+Linux+Mac等系统的版本。

[https://www.jenkins.io/download/](https://www.jenkins.io/download/)

![image-20240302184045917](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240302184045917.png)

本人极力推荐使用docker版本，后续维护性强 稳定性强。



可以在上面开发+定制你的自动化构建任务，然后将这个任务部署到内网/公网，其他工程师就可以远程访问了。

- 开发工程师用于触发构建 + 发版本
- 测试工程师用于下载固件 + 跑自动化测试

所以工程师之间互不干扰，少一些war！

 Jenkins的文件格式就是war，寓意（开发/测试/运维）不再有战争。



## 框架设计

如果产品规模小， 管理+编译+存放固件  可以在同一个服务器上进行也可以。

当时如果公司规模大，产品杂，就有必要每个服务器各司其职了。

如下是我简单描述的一个框架：

![image-20240305184407699](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240305184407699.png)



- Jenkins服务用于账号管理，Job管理，系统环境配置，系统插件配置，用户界面等

- 编译服务器用于代码下载，更新，编译，整理固件等

- FTP服务器用于按照规定命名/格式存放固件等，常常用于内部研发使用

- Jfrpg Artifacts就是类似于Jenkins的服务器应用，可以快速查找/搜索想要的固件，常用于给别的部门使用，或者释放给客户使用

- Jenkins Artifacts是自带的插件，存储和管理编译好的固件



## Jenkins部署

### 系统/插件配置

- 需要安装的系统插件：

- Publish over SSH：用ssh协议发送固件的

- E-mail：编译结果通知开发者

- Build Timestamp： 编译时间戳，每次会默认保存启动的时间戳

- ANSI Color： 颜色显示更加美观/明显

- Office 365 Connector： 用于Teams远程触发编译/结果同志， 企业微信也支持的

- Gitlab： 用于gitlab相关的

-  Repo： repo 相关的接口， manifest sync diff

- Build periodically with parameters ： 编译传入选项的UI控件

- Set Build Name： 设置任务编译名字的UI控件

- Active Choices： 可以选择的UI控件

- File Parameter： 用于传入文件的的UI控件

- Environment variables

- Rebuild

- ...

  

需要准备的系统配置：

- Publish over SSH

- E-mail，注意stmp的端口

- 内网的用户名+密码

- ...

  

### JOB配置

- 创建一个Job， 选择`Freestyle project`
- 创建编译的UI界面，使用控件`This project is parameterized`



如下，是我简单设计的UI模板：

______________________

BUILD_PROJECTS(构建的项目)

```
A10
B20
C50
```

BUILD_ANDROID_VERSION(项目的大版本)

```
a13
a11
a10
```

BUILD_VERSION_NUMBER(项目的版本号)

```

```

BUILD_SNAPSHOT(编译快照：将编译选项固定成一个标准的配置，方便于快速启动特定的构建)

```
daily_build
no
user+gms+ota
```

BUILD_INTENT（开发 or 正式发布 or jenkins调试）

```
dev
rel
jenkins_test
```

BUILD_SKU （是否支持GMS）

```
gms
aosp
```

BUILD_VARIANT（编译user/userdebug）

```
user
userdebug
eng
```

BUILD_TIMESTAMPS（是否指定时间戳）

```

```

-----------------

PACKAGES

- [ ] BUILD_FULL_OTA （OTA整包）

- [ ] BUILD_INC_OTA（OTA差分包）

  BUILD_SORCE_TARGETFILES_ID

  ```
  
  ```

  BUILD_TARGET_TARGETFILES_ID

  ```
  
  ```

- [ ] BUILD_SPECIAL_OTA  (客户定制包)

  ```
  no
  root ota
  ```

-------

BUILD_SOURCE_SYNC (代码同步)

- [ ] BUILD_RM_OUT (是否清除out环境)
- [ ] BUILD_REPO_SYNC (是否同步最新代码)

--------

SOURCE_CUSTOMZATION

- [ ] BUILD_HOOK_LOCAL_MANIFEST (hook local manifests)
```
[-----] chose files
```
- [ ] BUILD_HOOK_DEFAULT_MANIFEST (指定manifest文件)
```
[-----] chose files
```
- [ ] BUILD_REPO_HOOK_BEFORE_BUILD (编译前执行命令)
```
```

-----

POST_BUILDS （编译后处理）

BUILD_UPLOAD （上传到服务器）

```
Jenkins artifacts
FTP Server
JFROG
```

... ... 



UI控件设计实际效果如下：

![image-20240305184546432](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240305184546432.png)



... ...



## 源码编译

### 环境准备

android源码编译主要在编译服务器上运行，服务机最好能够Linux系统，内存大，CPU强悍，核数多。

需要安装以下必备的工具：

- android源码编译

  [https://source.android.com/docs/setup/build/building?hl=zh-cn](https://source.android.com/docs/setup/build/building?hl=zh-cn)

- git: 开发者必备的源码管理工具

- repo: 管理庞大的Android源码各个仓库，每个仓库都是git管理。 由于有2和3两个版本，建议两个都安装

- ssh/scp/rsync:  用于通过ssh协议传输文件，连接，同步

- python2 / python3 : 最好都安装，ota包的编译需要两者

- md5sum ：用于文件校验

  ... ...



### AOSP编译

#### 基本框架

![image-20240306154914902](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240306154914902.png)

- Jenkins UI

  相当于用户交互界面，相当于Jenkins的前端

  后端代码在Build Steps里面引用jenkins build scipts， 如下：

  ![image-20240306150515439](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240306150515439.png)

  

- jenkins_build_scipts

  用户在Jenkins UI定制自己需要的编译，这个脚本获取这些前端数据，调用AOSP编译脚本进行固件的生成，然后进行分发+处理，可以理解为Jenkins的后端

  

- aosp_build_scipts

  - 将被jenkins build scipts调用，是统一的编译脚本，需要使用统一的接口/入参/变量命名，可以适用于各个产品。
  - 此脚本应能避免掉高通/MTK产品编译方式的差异。不仅仅是jenkins使用，开发者平时也用



#### 编译脚本

##### aosp_build_scipts

aosp_build_scipts需要根据公司产品的特色和需求，自行定制和开发，大概的模板类似于：

```
./aosp_build.sh  [product_id] [variant] [gms/aosp] [sys/vnd/ota/inc_ota/...] [jobs]
```

也可以用环境变量的方式传入：

```
export product_id=A11; export variant=user; ... ; ./aosp_build.sh
```

根据产品特点和团队建议选择，这里不再赘述。



##### jenkins_build_scipts

- **Step1：获取用户数据**

jenkins获取前端主要是通过jenkins的环境变量加载功能实现。

![image-20240306161028439](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240306161028439.png)



- **Step2：编译执行**

  编译大致可以分为4个阶段：

  - Stage1: 环境变量处理 ： 

    根据前端需求，对于入参进行处理，

    比如对于snapshot快照编译，需要获取对应的配置文件，进行编译

    比如编译差分包，如果没有传入source targetfiles，就需要中断编译了，不然没有进行

  - Stage2: 代码处理：

    根据前端需求，使用repo进行init/sync工作，抑或是集成local_manifests，抑或是替换掉default manifest。

  - Stage3: 编译+固件预处理

    根据前端需求，进行编译需要的固件，由于aosp_build_scipts是统一的，所以可以无缝衔接。

    编译完成后，根据公司标准的命名格式，进行命名/打包，并分发到同一个jenkins build id下面，用于区分不同的构建。

  - Stage4: 固件发送+编译后工作

    编译完成后，

    如果代码有改动/调整，需要reset原来的状态

    如果有些简单的信息，需要自行测试，比如key是否正确，组件是否都集成。

    根据jenkins build id发送到对应的local FTP 服务器，jfrog服务器，客户网盘等等，以及回传到jenkins artifacts。

    这个过程中需要用scp等，可以自行百度无密码传输的方法。



编译脚本设计结构大致如下：

_________________________

MAIN: 

`./jenkins_build.sh` :  编译主函数



###### Stage1

`env_setup.sh`

- `env_init.sh` :  环境变量初始化
- `env_handler.sh` :  环境变量处理流程
- `env_hook_configs.sh` :   开放hook接口，也可以用于调试



###### Stage2

- `repo_init.sh` :   repo init 可以指定manifests的分支和具体的xml清单文件，以及处理local_manifests

- `repo_sync.sh` :  repo sync 可以指定是否清除本地修改/回退到最新/强制更新等

- `repo_handler.sh` :  repo manifest/diff/forall等操作



###### Stage3

`build_main.sh` :  编译主函数

`build_setup.sh` :  编译前准备工作，编译参数检验

- `build_image.sh` :  image编译主函数
  - `build_sys.sh` :  sys编译
  - `build_vnd.sh` :  vnd编译
  - `build_image_handler.sh` :  image打包
- `build_ota.sh` :  ota编译主函数
  - `build_full_ota.sh` :  整包
  - `build_inc_ota.sh` :  差分包
  - `build_customization_ota.sh` :  定制包
  - ... ...  

`build_artifacts_handler.sh` :  根据标准的命名格式，进行预处理/命名/打包



###### Stage4

`post_build_main.sh` :  

- `post_build_pretest.sh` : 编译完成后，是否进行基本信息的预测试，可以设置开关是否跑
- `source_handler.sh`: 编译完成后，是否需要代码调整处理
- `upload_main.sh` :  编译完成后，根据需要上传到固件到特定服务器



###### Projects：

- `init_product_a88.sh` : a88产品差异化的部分
- `init_product_a66.sh` : a66产品差异化的部分
- ...

###### Utils

- `log_utils.sh` :   log打印/调试

- `common_utils.sh` :  常用的工具代码
- `build_utils.sh` :  编译的工具代码
- `ssh_utils.sh` :  ssh相关的工具代码
- ...

_______________________________



## 发布管理

### FTP服务器

- 直接用 `Publish over SSH`，是Jenkins自带的工件发送
- 但是程序员该有自己的开发/定制化意识，最好是自行写脚本，这样有便于想怎么传就怎么传，而且不用踩坑



### jfrog

界面如下：

![image-20240306145824590](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240306145824590.png)

每个公司产品规划不同，不一定适用于每个公司。 如果要讲解jfrog，需要单独一篇文章了。



### Jenkins artifacts

`Jenkins Artifacts`是自带的插件，固件如果编译完，传回jenkins的特定目录：```${JENKINS_DATA_DIR}/jobs/${UPLOAD_BUILD_JOB_NAME}/builds/${UPLOAD_BUILD_ID}/archive```

就会显示在任务的build id下面：

![image-20240305183310716](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240305183310716.png)





## Tips

- docker ： 为了方便迁移服务器，解耦服务器环境的不同，最好将整个过程放置到docker

- ccache ： 为了提高编译速度，建议灵活使用ccache编译

- email / teams/ 企业微信 ：使用好通知机制，编译完是否成功，失败log等第一时间告知开发人员。 此外，还有远程触发编译的功能。

- display name ： 显示特定的项目名字
- Build periodically with parameters： 添加日构建机制，每天编译最新的版本
- descript name ： 编译完成后，显示可以找到固件的网络地址
-  ... ...



## 结语

- 这类工作理应是DevOps工程师做的，由于缺少HC，作为RD工程师，也顺带做了。老板致力于把我们培养成全栈工程师。
- 虽然是简单的编译工作，但是完整的开发，内容其实也挺多的，需要长时间debug。
- 一旦开发好，开发效率杆杆地提升，编译的便捷性也得到了提升。
- 能效工程虽然是辅助开发的，但是可以无形中明显提升RD进度和产品标准化。





