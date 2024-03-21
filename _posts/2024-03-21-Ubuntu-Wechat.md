---
layout: post
title: Install Wechat in Ubuntu 22.04(without wine)
categories: [devops, ubuntu]
description: some word here
keywords: devops, ubuntu
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



![v2-47493c4940b2848237a68238d4b521fe_720w](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/v2-47493c4940b2848237a68238d4b521fe_720w.jpg)

# Ubuntu22.04安装微信Linux版（非Wine版）

> Ubuntu下安装微信，一直是开发者痛点问题。微信终于推出了Linux原生版本（内侧版）。



## 下载

我已经将资源上传至：

```
https://download.csdn.net/download/dengtonglong/89003661
```

评论区有网盘的版本。



## 安装

```
sudo dpkg -i wechat-beta_1.0.0.145_amd64.fixed.deb 
```



可能会提示缺少libssl1.1：

```
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb 
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb 
```



卸载：

```
sudo dpkg --remove --force-remove-reinstreq wechat-beta
sudo rm -rf /var/lib/dpkg/info/wechat-beta.*
sudo dpkg -r wechat-beta
```



## 中文输入法

刚安装没法使用输入法，由于我的输入法是ibus，官方建议使用fcitx。由于wechat是基于QT开发，使用fcitx也在所难免。

准备安装最新的fcitx5。

```
sudo apt install fcitx5
sudo apt install fcitx5-chinese-addons
sudo apt install fcitx5-frontend-gtk3 fcitx5-frontend-gtk2
sudo apt install fcitx5-frontend-qt5 kde-config-fcitx5
```

在 Tweaks中将 Fcitx 5 添加到「开机启动程序」列表中即可。

![image-20240321104406147](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321104406147.png)

并将如下加入到环境变量：

```
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
```

设置中文输入法

![image-20240321104538963](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321104538963.png)

![image-20240321104647610](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321104647610.png)



设置为中文拼音之后，下一步就是引入词条，可以引入搜狗细胞词条，去官网下载即可。



## 体验

- 界面很清爽

  ![image-20240321105508986](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321105508986.png)

- 视频号

  <img src=https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321105555472.png width=300 height=300 />

- 小程序

![image-20240321105626421](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321105626421.png)

- 中文输入

  ![image-20240321110037938](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240321110037938.png)



## 已知的缺点

- 消息不能撤回和引用，不能点头像@和拍一拍
- 消息转发不能多选
- 文件（除视频）接收双击无法调用本地应用,仅打开下载文件夹目录
- 不能发送语音消息
- 只能拖入文件，不能拖出
- 部分linux发行版登录失败
- 不能导入和导出聊天记录
- 托盘显示异常
-  ...









