---
layout: fragment
title: 如何让VirtualBox系统使用Ubuntu主机的USB
categories: [linux]
description: some word here
keywords: usb, linux, Ubuntu
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



# 如何让VirtualBox系统使用Ubuntu主机的USB

当通过 VirtualBox 尝试不同的操作系统时，访问虚拟机中的 USB 驱动器来传输数据非常有用。



## 安装Guest Additions

自行百度安装Guest Additions的方法，最终的效果如下：

![image-20231029003651335](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029003651335.png)





## 将用户添加到 vboxusers 组

安装 VirtualBox 时，它会自动创建一个 vboxsuers 组。

要从虚拟机使用 USB 设备，主机操作系统用户必须是该组的成员。

在主机操作系统中，从开始菜单或活动概述搜索并打开终端取决于您的桌面环境。

打开终端后，复制并粘贴下面的命令，然后按回车键将当前用户添加到 vboxsuers 组。


```
cat /etc/group |  grep vboxusers
sudo gpasswd --add $USER vboxusers
```

![image-20231029003749391](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029003749391.png)

根据你的 Linux 发行版，你也可以使用

 ```sudo usermod -a -G vboxusers $USER```

 命令来代替。



然后通过

``` cat /etc/group |grep vboxusers ```

查看结果。



要应用更改，请重新启动主机（在我的情况下），或者尝试运行

``` sudo systemctl restart virtualbox.service``` 

命令来重新启动服务。



## 最终效果



![image-20231029030107015](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029030107015.png)



![image-20231029152046838](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029152046838.png)



这样，Windows虚拟机就可以使用Ubuntu主机系统的USB了。

