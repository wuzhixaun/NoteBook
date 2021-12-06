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

# 二、Tomcat 系统总体架构

![image-20211201221206280](https://cdn.wuzx.cool/image-20211201221206280.png)

Tomcat 设计了两个核心组件连接器(**Connector**)和容器(**Container**)来完成 Tomcat 的两大核心 功能

`连接器`: 负责对外交流: 处理Socket连接，负责网络字节流与Request和Response对象的转化

`容器`:负责内部处理:加载和管理Servlet，以及具体处理Request请求



#  三、Coyote Tomcat 连接器组件

## 3.1 **Coyote** 简介

 Coyote 是Tomcat 中连接器的组件名称 , 是对外的接口。客户端通过Coyote与服务器建立连接、发送请 求并接受响应

+ Coyote 封装了底层的网络通信(Socket 请求及响应处理)
+ Coyote 使Catalina 容器(容器组件)与具体的请求协议及IO操作方式完全解耦
+ Coyote 将Socket 输入转换封装为 Request 对象，进一步封装后交由Catalina 容器进行处理，处 理请求完成后, Catalina 通过Coyote 提供的Response 对象将结果写入输出流
+ Coyote 负责的是具体协议(应用层)和**IO**(传输层)相关内容

![image-20211201221531773](https://cdn.wuzx.cool/image-20211201221531773.png)

## 3.2Coyote 的内部组件及流程 

![image-20211201221811247](https://cdn.wuzx.cool/image-20211201221811247.png)

![image-20211201221830487](https://cdn.wuzx.cool/image-20211201221830487.png)

# 四、**Tomcat Servlet** 容器 Catalina

## 4.1 **Tomcat** 模块分层结构图及**Catalina**位置

> **Tomcat** 本质上就是一款 **Servlet** 容器， 因为 Catalina 才是 Tomcat 的核心 ， 其 他模块都是为Catalina 提供支撑的。 比如 : 通过 Coyote 模块提供链接通信，Jasper 模块提供 JSP 引 擎，Naming 提供JNDI 服务，Juli 提供日志服务

![image-20211201221906393](https://cdn.wuzx.cool/image-20211201221906393.png)

## 4.2 **Servlet** 容器 **Catalina** 的结构

![image-20211201222024096](https://cdn.wuzx.cool/image-20211201222024096.png)

Tomcat就是一个Catalina实例，Tomcat 启动的时候会初始化这个实例，Catalina 实例通过加载server.xml完成其他实例的创建，创建并管理一个Server，Server创建并管理多个服务， 每个服务又可以有多个Connector和一个Container。

+ 一个Catalina实例(容器)
+ 一个 Server实例(容器)
+ 多个Service实例(容器)

> + Catalina: 负责解析Tomcat的配置文件(server.xml) , 以此来创建服务器Server组件并进行管理
> + Server: 服务器表示整个Catalina Servlet容器以及其它组件，负责组装并启动Servlaet引擎,Tomcat连接 器。Server通过实现Lifecycle接口，提供了一种优雅的启动和关闭整个系统的方式
> + Service: 服务是Server内部的组件，一个Server包含多个Service。它将若干个Connector组件绑定到一个 Container
> + Container 容器，负责处理用户的servlet请求，并返回对象给web用户的模块

## 4.3 **Container**

Container组件下有几种具体的组件，分别是Engine、Host、Context和Wrapper。这4种组件(容器)

### Engine

表示整个Catalina的Servlet引擎，用来管理多个虚拟站点，一个Service最多只能有一个Engine， 但是一个引擎可包含多个Host

### Host

代表一个虚拟主机，或者说一个站点，可以给Tomcat配置多个虚拟主机地址，而一个虚拟主机下可包含多个Context

### Context

表示一个Web应用程序， 一个Web应用可包含多个Wrapper

### Wrapper

表示一个Servlet，Wrapper 作为容器中的最底层，不能包含子容器