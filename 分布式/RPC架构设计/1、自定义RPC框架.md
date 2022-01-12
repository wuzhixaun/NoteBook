# 一、**分布式架构网络通信**

> 在分布式服务框架中，一个最基础的问题就是远程服务是怎么通讯的，在Java领域中有很多可实现 远程通讯的技术，例如:RMI、Hessian、SOAP、ESB和JMS等，它们背后到底是基于什么原理实现的

## 1.1 **基本原理**

> 网络 通信需要做的就是将流从一台计算机传输到另外一台计算机，基于传输协议和网络IO来实现，其中传输 协议比较出名的有tcp、udp等等，tcp、udp都是在基于Socket概念上为某类应用场景而扩展出的传输 协议，网络IO，主要有bio、nio、aio三种方式，所有的分布式应用通讯都基于这个原理而实现

## 1.2 **什么是RPC**
RPC全称为remote procedure call，即远程过程调用。借助RPC可以做到像本地调用一样调用远程服务，是一种进程间的通信方式. **RPC并不是一个具体的技术，而是指整个网络远程调 用过程。**

![image-20220113000831187](https://cdn.wuzx.cool/image-20220113000831187.png)

## 1.3 RPC架构
一个完整的RPC架构里面包含了四个核心的组件，分别是`Client`，`Client Stub`，`Server`以及`ServerStub`，这个Stub可以理解为存根。

+ 客户端(Client)，服务的调用方。
+  客户端存根(Client Stub)，存放服务端的地址消息，再将客户端的请求参数打包成网络消息，然后 通过网络远程发送给服务方。
+  服务端(Server)，真正的服务提供者。
+ 服务端存根(Server Stub)，接收客户端发送过来的消息，将消息解包，并调用本地的方法。



### RPC调用过程

![image-20220113001041626](https://cdn.wuzx.cool/image-20220113001041626.png)

# 二、RPC框架介绍

> 在java中RPC框架比较多，常见的有Hessian、gRPC、Dubbo 等，其实对 于RPC框架而言，核心模块 就是**通讯和序列化**

无论是何种类型的数据，最终都需要转换成二进制流在网络上进行传输，数据的发送方需要 将对象转换为二进制流，而数据的接收方则需要把二进制流再恢复为对象。

## 2.1 **RMI**

> Java RMI，即远程方法调用(Remote Method Invocation)，一种用于实现**远程过程调用**(RPC- Remote procedure call)的Java API， 能直接传输序列化后的Java对象。它的实现依赖于Java虚拟机，因 此它仅支持从一个JVM到另一个JVM的调用

![image-20220113001815889](https://cdn.wuzx.cool/image-20220113001815889.png)

## 代码实现



### 服务端

``` java
public class RMIServer {

    public static void main(String[] args) {
        try {
            // 1、注册Registry实例，绑定端口
            final Registry registry = LocateRegistry.createRegistry(9998);

            // 2.创建远程对象
            IUserService iUserService = new IUserServiceImpl();

            // 3、将远程对象注册到RMI服务器上
            registry.rebind("userService", iUserService);

            System.out.println("RMI服务端启动成功");

        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }
}
```

### 客户端

``` java
public class RMIClient {


    public static void main(String[] args) {
        try {
            // 1、获取Registry对象
            final Registry registry = LocateRegistry.getRegistry("127.0.0.1", 9998);
            // 2、查找对应的远程对象
            final IUserService userService = (IUserService) registry.lookup("userService");

            final User user = userService.getByUserId(1);

            System.out.println(user);
        } catch (RemoteException | NotBoundException e) {
            e.printStackTrace();
        }

    }
}
```

### 结果展示

``` html
User{id=1, name='张三'}
```

