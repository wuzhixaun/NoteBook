# 一、nginx基本概念

## 1.简介

> *Nginx* (engine x) 是一个高性能的[HTTP](https://baike.baidu.com/item/HTTP)和[反向代理](https://baike.baidu.com/item/反向代理/7793488)web服务器，同时也提供了IMAP/POP3/SMTP服务。Nginx是由伊戈尔·赛索耶夫为[俄罗斯](https://baike.baidu.com/item/俄罗斯/125568)访问量第二的Rambler.ru站点（俄文：Рамблер）开发的，第一个公开版本0.1.0发布于2004年10月4日
>
> Nginx是一款[轻量级](https://baike.baidu.com/item/轻量级/10002835)的[Web](https://baike.baidu.com/item/Web/150564) 服务器/[反向代理](https://baike.baidu.com/item/反向代理/7793488)服务器及[电子邮件](https://baike.baidu.com/item/电子邮件/111106)（IMAP/POP3）代理服务器，在BSD-like 协议下发行。**其特点是占有内存少，[并发](https://baike.baidu.com/item/并发/11024806)能力强**，事实上nginx的并发能力在同类型的网页服务器中表现较好，中国大陆使用nginx网站用户有：百度、[京东](https://baike.baidu.com/item/京东/210931)、[新浪](https://baike.baidu.com/item/新浪/125692)、[网易](https://baike.baidu.com/item/网易/185754)、[腾讯](https://baike.baidu.com/item/腾讯/112204)、[淘宝](https://baike.baidu.com/item/淘宝/145661)等。



## 2.Nginx 作为 web 服务器

>Nginx 可以作为静态页面的 web 服务器，同时还支持 CGI 协议的动态语言，比如 perl、php 等。但是不支持 java。Java 程序只能通过与 tomcat 配合完成。Nginx 专为性能优化而开发， 性能是其最重要的考量,实现上非常注重效率 ，能经受高负载的考验,有报告表明能支持高 达 50,000 个并发连接数。
>
>https://lnmp.org/nginx.html



## 3.反向代理

### 3.1正向代理

**简单来说就是：需要在客户端配置代理服务器进行指定网站访问**

> Nginx 不仅可以做反向代理，实现负载均衡。还能用作正向代理来进行上网等功能。 正向代理:如果把局域网外的 Internet 想象成一个巨大的资源库，则局域网中的客户端要访 问 Internet，则需要通过代理服务器来访问，这种代理服务就称为正向代理

![](/Users/wuzhixuan/NoteBook/nginx/image-20210928230654682.png)



### 3.2 反向代理

**简单来说：暴露的是代理服务器地址，隐藏了真实服务器 IP 地址**

> 反向代理，其实客户端对代理是无感知的，因为客户端不需要任何配置就可以访问，我们只
>
> 需要将请求发送到反向代理服务器，由反向代理服务器去选择目标服务器获取数据后，在返
>
> 回给客户端，此时反向代理服务器和目标服务器对外就是一个服务器，暴露的是代理服务器
>
> 地址，隐藏了真实服务器 IP 地址。

![image-20210928231350438](/Users/wuzhixuan/NoteBook/nginx/image-20210928231350438.png)



## 4.负载均衡

> 我们增加服务器的数量，然后将请求分发到各个服务器上，将原先请求集中到单个服务器上的情况改为将请求分发到多个服务器上，将负载分发到不同的服务器，也就是我们 所说的负载均衡

![image-20210928232039461](/Users/wuzhixuan/NoteBook/nginx/image-20210928232039461.png)

![image-20210928231858513](/Users/wuzhixuan/NoteBook/nginx/image-20210928231858513.png)



## 5.动静分离

> 为了加快网站的解析速度，可以把动态页面和静态页面由不同的服务器来解析，加快解析速度。降低原来单个服务器的压力。

![image-20210928232539715](/Users/wuzhixuan/NoteBook/nginx/image-20210928232539715.png)







# 二、nginx安装、常用命令和配置文件

## 2.1安装 nginx

> 需要安装 pre、openssl、zlib、nginx

### 第一步，安装 pcre

``` shell
wget http://downloads.sourceforge.net/project/pcre/pcre/8.37/pcre-8.37.tar.gz
```

### 第二步，安装 openssl

### 第三步，安装 zlib

``` shell
yum -y install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel
```

### 第四步，安装 nginx

> 1、 解压缩 nginx-xx.tar.gz 包。
>
> 2、 进入解压缩目录，执行./configure。
>
>  3、 make && make install



**安装成功之后，在`usr`会多出来一个文件夹`loacl/nginx`,在nginx有sbin有启动脚本**



### 个人是使用docker 来启动nginx

``` shell
docker run --name nginx -d -p 80:80 -v /Users/wuzhixuan/nginx/html:/usr/share/nginx/html -v /Users/wuzhixuan/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v /Users/wuzhixuan/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf -v /Users/wuzhixuan/nginx/logs:/var/log/nginx nginx


docker run --name test -d  -p 80:80  nginx

docker cp test:/etc/nginx/nginx.conf /Users/wuzhixuan/nginx/conf/nginx.conf                                   
docker cp test:/etc/nginx/conf.d/default.conf  /Users/wuzhixuan/nginx/conf.d/default.conf



```





# 三、nginx配置实例



