---
layout: fragment
title: Use Crontab to build timer task in Linux
tags: [linux]
description: efficeny
keywords: ubuntu, crontab, timer
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

# 使用crontab创建定制化定时器任务(Linux/Ubuntu)

## 官网信息

[https://crontab.guru/](https://crontab.guru/)

![image-20231009114623019](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231009114623019.png)

查看使用案例：

点击[examples](https://crontab.guru/examples.html)

![image-20231009114816378](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231009114816378.png)



## 实践操作

### help

```
crontab -h
crontab: invalid option -- 'h'
crontab: usage error: unrecognized option
usage:	crontab [-u user] file
	crontab [ -u user ] [ -i ] { -e | -l | -r }
		(default operation is replace, per 1003.2)
	-e	(edit user's crontab)
	-l	(list user's crontab)
	-r	(delete user's crontab)
	-i	(prompt before deleting user's crontab)
```



### set task

需求：每5分钟保存ifconfig信息

- 启动编辑

```
crontab -e 
```

- 配置

  ![image-20231009115212204](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231009115212204.png)

- Ctrl+O保存

  ![image-20231009115253452](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231009115253452.png)

- Ctrl+X退出

- 查看是否配置成功

  ```
  crontab -l
  ```

  

## 总结

每分钟执行一次：

```shell
* * * * * * python pythonScript.py
```



每5分钟执行一次：

```shell
*/5 * * * * /bin/sh xxxx/xxxx.sh
```



每天执行一次：

```shell
0 0 * * * /bin/sh xxxx/xxxx.sh
```



可以根据需要，将所有需要执行的命令写在一个sh脚本中，然后执行。

```shell
*/1 * * * * /bin/sh xxxx/task_every_minute.sh
*/5 * * * * /bin/sh xxxx/task_every_5_minute.sh
0 * * * *   /bin/sh xxxx/task_every_60_minute.sh
0 0 * * *   /bin/sh xxxx/task_every_day.sh
0 0 * * 0   /bin/sh xxxx/task_every_week.sh
0 0 1 * *   /bin/sh xxxx/task_every_month.sh
```













