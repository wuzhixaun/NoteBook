# 一、浏览器访问服务器的流程

http请求的处理过程

![image-20211201000022215](https://cdn.wuzx.cool/image-20211201000022215.png)

![image-20211201000034880](https://cdn.wuzx.cool/image-20211201000034880.png)

注意:浏览器访问服务器使用的是Http协议，Http是应用层协议，用于定义数据通信的格式，具体的数 据传输使用的是TCP/IP协议

# 二、**Tomcat** 系统总体架构

## 2.1**Tomcat** 请求处理大致过程

**Tomcat**是一个**Http**服务器(能够接收并且处理**http**请求，所以**tomcat**是一个**http**服务器)

> 我们使用浏览器向某一个网站发起请求，发出的是Http请求，那么在远程，Http服务器接收到这个请求 之后，会调用具体的程序(Java类)进行处理，往往不同的请求由不同的Java类完成处理

![image-20211201000452340](https://cdn.wuzx.cool/image-20211201000452340.png)

![image-20211201000549509](https://cdn.wuzx.cool/image-20211201000549509.png)

HTTP 服务器接收到请求之后把请求交给Servlet容器来处理，Servlet 容器通过Servlet接口调用业务 类。**Servlet**接口和**Servlet**容器这一整套内容叫作**Servlet**规范

注意:Tomcat既按照Servlet规范的要求去实现了Servlet容器，同时它也具有HTTP服务器的功能。 Tomcat的两个重要身份
 1)http服务器
 2)Tomcat是一个Servlet容器