gnome-session-properties

```
gnome-system-monitor
```



shell开启alias：

shopt -s  expand_aliases 

https://www.cnblogs.com/chenjo/p/11145021.html



sudo 自动输入密码：

```
#!/bin/bash
echo 密码 | sudo -S ls
 
 
Or
echo 密码 | sudo -s ls
 
注释：
-S, --stdin : 从标准输入读取密码
-s, --shell : 以目标用户运行 shell；可同时指定一条命令
```



https://blog.csdn.net/u010164190/article/details/125421126







