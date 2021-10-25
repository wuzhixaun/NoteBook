# 一、Netty概述

官方的介绍：
Netty is *an asynchronous event-driven network application framework*
for rapid development of maintainable high performance protocol servers & clients.
**Netty**是 一个**异步事件驱动**的网络应用程序框架，用于**快速开发可维护的高性能协议服务器和客户端**。

# 二、为什么使用Netty

从官网上介绍，Netty是一个网络应用程序框架，开发服务器和客户端。也就是用于网络编程的一个框架。既然是网络编程，Socket就不谈了，为什么不用NIO呢？

## 2.1 NIO的缺点

+ NIO的类库和API繁杂，学习成本高，你需要熟练掌握Selector、ServerSocketChannel、SocketChannel、ByteBuffer等
+ 需要熟悉Java多线程编程。这是因为NIO编程涉及到Reactor模式，你必须对多线程和网络编程非常熟悉，才能写出高质量的NIO程序
+ 臭名昭著的epoll bug。它会导致Selector空轮询，最终导致CPU 100%。直到JDK1.7版本依然没得到根本性的解决

## 2.2 Netty的优点

- API使用简单，学习成本低。
- 功能强大，内置了多种解码编码器，支持多种协议。
- 性能高，对比其他主流的NIO框架，Netty的性能最优。
- 社区活跃，发现BUG会及时修复，迭代版本周期短，不断加入新的功能。
- Dubbo、Elasticsearch都采用了Netty，质量得到验证。

# 三、架构

![preview](https://pic3.zhimg.com/v2-8552db7ceabc450d9e0eb8db689155d6_r.jpg)

+ 绿色的部分**Core**核心模块，包括零拷贝、API库、可扩展的事件模型。
+ 橙色部分**Protocol Support**协议支持，包括Http协议、webSocket、SSL(安全套接字协议)、谷歌Protobuf协议、zlib/gzip压缩与解压缩、Large File Transfer大文件传输等等
+ 红色的部分**Transport Services**传输服务，包括Socket、Datagram、Http Tunnel等等。
    以上可看出Netty的功能、协议、传输方式都比较全，比较强大。

# 四、搭建永远的 Hello Word

![img](https://pic4.zhimg.com/80/v2-7eefba893a65706eb6bbe4115cbd0b83_720w.jpg)

## 4.1 引入Maven依赖

``` xml
使用的版本是4.1.20，相对比较稳定的一个版本。
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
    <version>4.1.20.Final</version>
</dependency>
```

