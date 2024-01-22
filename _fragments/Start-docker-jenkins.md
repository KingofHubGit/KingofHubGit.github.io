---
layout: fragment
title: How to start Jenkins with docker
categories: [jenkins, devops]
description: some word here
keywords: jenkins, docker, devops
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![jenkins-docker01](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/jenkins-docker01.png)



# Docker-Jenkins提示各种证书错误的解决方案

> 本文主要介绍docker-jenkins安装、简易启用，以及讲述这个过程遇到的坑，特别是各种证书错误的问题。



在做IT开发过程中，经常要接触CI/CD的工具，比如Jenkins。

## 下载与安装

### 下载Jenkins

https://www.jenkins.io/download/

![image-20240122152729710](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122152729710.png)

根据需要自行选择

为啥我个人强烈建议下载Docker版jenkins？

- jenkins应用和数据全面解耦，程序和数据隔离，少出问题；
- jenkins以及内置的程序，可以随时升降级；
- jenkins数据可以随时备份，插件和系统配置移植性强；



### 安装docker-jenkins

拉取docker

```
docker pull jenkins/jenkins
docker images
```

创建docker-jenkins的数据目录

```
mkdir -p /home/ldeng/code/Docker/home/jenkins_home/
chmod 777 /home/ldeng/code/Docker/home/jenkins_home/
```

运行docker-jenkins

```
docker run --rm -p 8082:8080 -p 50000:50000 \
-v /home/ldeng/code/Docker/home/jenkins_home/:/var/jenkins_home \
-v /etc/localtime:/etc/localtime \
--name lucasd-jenkins \
jenkins/jenkins:latest
```

/etc/localtime是同步外部系统时区。

启动后记住管理密码：

```
 /var/jenkins_home/secrets/initialAdminPassword
```

然后http://localhost:8082 登录

- 输入密码
  - 安装推荐的插件
    - 如果安装失败，进入jenkins系统后，修改插件源，然后再重新安装



## 遇到的问题

### 下载插件提示证书不对

由于亲自踩过坑，所以在此直接说答案：

安装“skip-certificate-check”插件

![image-20240105235520373](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240105235520373.png)



### 下载内网代码提示证书不对



![image-20240122154258047](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122154258047.png)

- 配置ssh

**记住用户名一定要写jenkins**

![image-20240122154514789](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122154514789.png)

貌似可以了？还是错了！

![image-20240122154630171](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122154630171.png)

docker-jenkins里面根本没有一些常用的证书以及内网的证书。

docker里面的网络环境和本地不一致， 加上--network host

```
docker run  --network host
```



其次，不仅仅是google官方的库，还有功能内部gitlab的证书也提示错误，于是想办法怎么默认安装上证书。

经过努力，终于找到Ubuntu通用的证书路径为：

```
/etc/ssl/certs/
/usr/share/ca-certificates/
```

最终找到了**解决方案**：

```
docker run  --network host  --rm -p 8080:8080 -p 50000:50000   \
-v /home/ldeng/code/Docker/home/jenkins_home/:/var/jenkins_home  \
-v /etc/localtime:/etc/localtime  \
-v /etc/ssl/certs/:/etc/ssl/certs/ \
-v /usr/share/ca-certificates/:/usr/share/ca-certificates/ \
--name lucasd-jenkins  jenkins/jenkins:latest
```



该映射的需要映射，比如docker中没有ping工具，也可以这样：

```
-v /usr/bin/ping:/usr/bin/ping
```



在我看来，如果是公司内部用于开发的docker，需要默认集成如上证书/时区/binary等，而不是让开发者去踩坑。

但考虑本文用的是官方的docker jenkins，所以映射也在所不辞。

