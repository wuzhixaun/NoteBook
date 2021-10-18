[TOC]
# 1. nginx操作常用命令

>使用nginx操作命令前提条件：必须进入nginx的目录`/usr/local/nginx/sbin`



## 1.1查看nginx版本号

``` shell
# nginx -v
nginx version: nginx/1.21.3 
```

## 1.2 启动nginx

``` shell
nginx -s start
```

## 1.3 关闭nginx

``` shell
nginx -s stop
```

## 1.4重新加载nginx

```shell
  nginx -s reload
```



# 2.Nginx 配置文件

> nginx 配置文件的位置 `/usr/local/nginx/`



## 第一部分:全局块

> 从配置文件开始到 events 块之间的内容，主要会设置一些影响 nginx 服务器整体运行的配置指令，主要包括配 置运行 Nginx 服务器的用户(组)、允许生成的 worker process 数，进程 PID 存放路径、日志存放路径和类型以 及配置文件的引入等。

## 第二部分:events 块

> events 块涉及的指令主要影响 Nginx 服务器与用户的网络连接，常用的设置包括是否开启对多 work process 下的网络连接进行序列化，是否允许同时接收多个网络连接，选取哪种事件驱动模型来处理连接请求，每个 word process 可以同时支持的最大连接数等。
>
> 上述例子就表示每个 work process 支持的最大连接数为 1024. 这部分的配置对 Nginx 的性能影响较大，在实际中应该灵活配置。



## 第三部分:http 块

### 1、http 全局块

http 全局块配置的指令包括文件引入、MIME-TYPE 定义、日志自定义、连接超时时间、单链接请求数上限等。

### 2、server 块

#### 1、全局 server 块

> 最常见的配置是本虚拟机主机的监听配置和本虚拟主机的名称或 IP 配置。

#### 2、location 块

> 一个 server 块可以配置多个 location 块。这块的主要作用是基于 Nginx 服务器接收到的请求字符串(例如 server_name/uri-string)，对虚拟主机名称 (也可以是 IP 别名)之外的字符串(例如 前面的 /uri-string)进行匹配，对特定的请求进行处理。地址定向、数据缓 存和应答控制等功能，还有许多第三方模块的配置也在这里进行。

## 配置文件内容

    user  nginx;                                    #全局有效
    worker_processes  1;   # worker_processes 值越大，可以支持的并发处理量也越多，但是 会受到硬件、软件等设备的制约
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;
    events {
        worker_connections  1024;                   #只在events中有效
    }
    http {                                          #以下指令在http部分中生效
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;
        ...
    }

- `user` 表示谁有权使用nginx服务
- `group` 表示哪个用户组可以使用nginx服务
- 如果都允许使用nginx服务,那么直接不写user或者`user nobody nobody`
- user只能在全局块中配置

## nginx.conf文件结构

``` yaml
  ...                      #全局块
  events{}                 #events块
  http{                    #http块
      ...                  #http全局块
      server{              #server块
        ...                #server全局块
        location [/]{      #location块
          ...
        }
      }
    }
   ...
```

- 全局块:nginx服务器的配置信息
- events块:主要影响nginx服务器与用户的网络连接,
- http块:代理缓存和日志定义绝大多数功能和第三方模块的配置可以放这
- server块:每个server相当于一台虚拟主机,它内部可以有多台主机联合提供服务,一起对外提供在逻辑上关系密切的一组服务
- location:基于nginx服务器接收到的请求字符串,对除虚拟主机名之外的字符串进行匹配,对特定的请求进行处理



# 3.Nginx配置实例

## 3.1反向代理实例

> 实现效果:使用 nginx 反向代理，访问 www.123.com 直接跳转到www.baidu.com

+ 在本地配置host映射 建议可以下载 **Switchhost**这个软件
+ 

