---
layout: fragment
title: How to build android-app by Jenkins with docker
categories: [android,jenkins]
description: some word here
keywords: android,jenkins, docker, devops
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



![jenkins-docker-android](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/jenkins-docker-android.png)

# Docker-Jenkins编译android-app的两种方案

> android开发使用jenkins编译，自动集成修改点/自动命名/自动备份，将修改的apk发布到测试服务器+发布网盘，而不需要用通讯工具传来传去。
>
> jenkins用在互联网开发编译比较常见，如果android开发也想用，该怎么设计呢？



由于用jenkins开发android app的文章比较多，本文只提炼了干货。



## 关键点1

在app端需要做哪些修改？

- 使用android studio开发，IDE会帮忙默认签名。

  而用jenkins编译肯定要用到gradle编译，所以需要在build.gradle里面加入针对于jenkins编译需要做自行签名的代码。

  ```
  android {
      signingConfigs {
          debug {
              storeFile file('.\\as_key.jks')
              storePassword '123456'
              keyPassword '123456'
              keyAlias 'key0'
          }
          release {
              storeFile file('.\\as_key.jks')
              storePassword '123456'
              keyPassword '123456'
              keyAlias 'key0'
          }
      }
  }
  ```

- local.properties中的sdk.dir需要改为jenkins可以用到sdk



## 关键点2

Android SDK+JDK的配置

- 可以在Jenkins的Tools里面配置本地路径
- 也可以引用/映射本地的SDK环境，包括java环境
- Docker里面一般只有一个固定的jdk  android sdk版本，但你需要下载编译你app对应的环境

包括gradle版本也是头疼的事情，建议google官方出一个集成常用jdk+常用android sdk+特定gradle版本的docker，但是镜像的体积估计不会小，几个G应该有。



以下是我个人启动docker通过映射启动的方式：

```
docker run  --network host  --rm -p 8080:8080 -p 50000:50000   
-v /home/ldeng/code/Docker/home/jenkins_home/:/var/jenkins_home   
-v /etc/localtime:/etc/localtime  
-v /home/ldeng/code/Android/Sdk:/var/jenkins_home/workspace/AndroidSDK 
-v /usr/lib/jvm/java-11-openjdk-amd64/:/var/jenkins_home/workspace/jdk11/ 
-v /usr/lib/jvm/java-8-openjdk-amd64/:/var/jenkins_home/workspace/jdk8/  
-v /home/ldeng/.gradle/:/var/jenkins_home/.gradle     
--name lucasd-jenkins  jenkins/jenkins:latest
```





## 关键点3

如何编译？ 废话，用gradle。



### 下载代码

![image-20240106092627686](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240106092627686.png)



### 方案一：使用gradle编译

1. 先配置gradle

   ![image-20240106092740919](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240106092740919.png)

   >  但是这种配置方式，必须要和app默认支持的gradle版本保持一直，必须也是6.5的版本

2. 使用gradle编译

![image-20240122164406767](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122164406767.png)





3. 注意task需要填写：

```
app:clean
app:assembleDebug
```

4. 编译完成：

![image-20240106092807971](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240106092807971.png)



### 方案二：使用gradlew编译

如果不想gradle版本被限制死了就需要用gradlew的方式编译，

它会自动解析当前项目支持哪个版本的gradle。

![image-20240122164639334](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122164639334.png)

但是需要映射gradle下载的缓存路径：

```
-v /home/ldeng/.gradle/:/var/jenkins_home/.gradle
```

这个很重要！

不然每次下载都要下载一次gradle 6.5, 这个时间是比较长的，所以建议映射到本地gradle路径。



脚本代码：

```shell
pwd
ls
export ANDROID_HOME=/var/jenkins_home/workspace/AndroidSDK
export ANDROID_SDK_ROOT=/var/jenkins_home/workspace/AndroidSDK
export ANDROID_SDK_ROOT=/var/jenkins_home/workspace/jdk8
export GRADLE_HOME=/var/jenkins_home/.gradle/wrapper/dists/gradle-6.5-bin/6nifqtx7604sqp1q6g8wikw7p/gradle-6.5
export GRADLE_USER_HOME=/var/jenkins_home/.gradle
echo $ANDROID_HOME
echo $ANDROID_SDK_ROOT
echo $JAVA_HOME
echo $GRADLE_HOME
#ls /var/jenkins_home/workspace/AndroidSDK
/usr/bin/env bash gradlew clean
/usr/bin/env bash gradlew assembleDebug
```





## 关键点4

发送apk/jar/arr等工件到测试服务器，

用到了Publish artifacts over SSH

![image-20240106101125920](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240106101125920.png)

![image-20240106101200235](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240106101200235.png)



