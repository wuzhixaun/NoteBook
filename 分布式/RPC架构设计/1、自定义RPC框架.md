

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

# 三、基于Netty实现RPC框架

## 3.1 Netty模型

![image-20220114152243571](https://cdn.wuzx.cool/image-20220114152243571.png)

+ Netty 抽象出两组线程池：`BossGroup` 和 `WorkerGroup`，也可以叫做`BossNioEventLoopGroup` 和 `WorkerNioEventLoopGroup`。每个线程池中都有`NioEventLoop 线程`。`BossGroup `中的线程专门负责和客户端建立连接，`WorkerGroup` 中的线程专门负责处理连接上的读写。`BossGroup` 和 `WorkerGroup` 的类型都是`NioEventLoopGroup`

+ `NioEventLoopGroup `相当于一个事件循环组，这个组中含有多个事件循环，每个事件循环就

    是一个 `NioEventLoop`

+ NioEventLoop 表示一个不断循环的执行事件处理的线程，每个 NioEventLoop 都包含一个

    Selector，用于监听注册在其上的 Socket 网络连接（Channel）

+ NioEventLoopGroup 可以含有多个线程，即可以含有多个 NioEventLoop

+  BossNioEventLoop 循环执行以下三个步骤

    + **select**：轮询注册在其上的 ServerSocketChannel 的 accept 事件（OP_ACCEPT 事件）
    + **processSelectedKeys**：处理 accept 事件，与客户端建立连接，生成一个`NioSocketChannel`，并将其注册到某个 `WorkerNioEventLoop` 上的 Selector 上
    + **runAllTasks**：再去以此循环处理任务队列中的其他任务

+ WorkerNioEventLoop 循环执行以下三个步骤

    + **select**：轮训注册在其上的 NioSocketChannel 的 read/write 事件（OP_READ/OP_WRITE 事件）
    + **processSelectedKeys**：在对应的 NioSocketChannel 上处理 read/write 事件
    + **runAllTasks**：再去以此循环处理任务队列中的其他任务

+ 在以上两个**processSelectedKeys**步骤中，会使用 Pipeline（管道），Pipeline 中引用了

    Channel，即通过 Pipeline 可以获取到对应的 Channel，Pipeline 中维护了很多的处理器

    （拦截处理器、过滤处理器、自定义处理器等）。

## 3.2 核心API介绍

### 3.2.1 ChannelHandler

> Netty开发中需要自定义一个 Handler 类去实现 ChannelHandle接口或其子接口或其实现类

![image-20220114154256950](https://cdn.wuzx.cool/image-20220114154256950.png)

> public void channelActive(ChannelHandlerContext ctx)，通道就绪事件
>
> public void channelRead(ChannelHandlerContext ctx, Object msg)，通道读取数据事件
>
> public void channelReadComplete(ChannelHandlerContext ctx) ，数据读取完毕事件
>
> public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause)，通道发生异常事
>
> 件

### 3.2.2 **ChannelPipeline**

> ChannelPipeline 是一个 Handler 的集合，它负责处理和拦截 inbound 或者 outbound 的事件和操作，相当于一个贯穿 Netty 的责任链.



![image-20220114154434538](https://cdn.wuzx.cool/image-20220114154434538.png)

**InboundHandler**是按照Pipleline的加载顺序的顺序执行, OutboundHandler是按照Pipeline的加载顺序，逆序执行

### 3.2.3 **ChannelHandlerContext**

> 这 是 事 件 处 理 器 上 下 文 对 象 ， Pipeline 链 中 的 实 际 处 理 节 点 。 每 个 处 理 节 点ChannelHandlerContext 中 包 含 一 个 具 体 的 事 件 处 理 器 ChannelHandler ,同时ChannelHandlerContext 中也绑定了对应的 ChannelPipeline和 Channel 的信息，方便对ChannelHandler 进行调用。常用方法如下所示：

+ ChannelFuture close()，关闭通道
+ ChannelOutboundInvoker flush()，刷新
+ ChannelFuture writeAndFlush(Object msg) ， 将 数 据 写 到 ChannelPipeline 中 当 前ChannelHandler 的下一个 ChannelHandler 开始处理（出站）

### 3.2.4 **ChannelOption**

> Netty 在创建 Channel 实例后,一般都需要设置 ChannelOption 参数。ChannelOption 是 Socket 的标准参数，而非 Netty 独创的。常用的参数配置有：
>
> + `ChannelOption.SO_BACKLOG`
>
>      对应 TCP/IP 协议 listen 函数中的 backlog 参数，用来初始化服务器可连接队列大小。服务端处理客户端连接请求是顺序处理的，所以同一时间只能处理一个客户端连接。多个客户 端来的时候，服务端将不能处理的客户端连接请求放在队列中等待处理，backlog 参数指定 了队列的大小。
>
> + `ChannelOption.SO_KEEPALIVE `
>
>     一直保持连接活动状态。该参数用于设置TCP连接，当设置该选项以后，连接会测试链接的状态，这个选项用于可能长时间没有数据交流的连接。当设置该选项以后，如果在两小时内没有数据的通信时，TCP会自动发送一个活动探测数据报文。

### 3.2.5 **ChannelFuture**

> 表示 Channel 中异步 I/O 操作的结果，在 Netty 中所有的 I/O 操作都是异步的，I/O 的调用会直接返回，调用者并不能立刻获得结果，但是可以通过 ChannelFuture 来获取 I/O 操作 的处理状态

+ `Channel channel()` 返回当前正在进行 IO 操作的通道
+ `ChannelFuture sync()` 等待异步操作执行完毕,将异步改为同步

### 3.2.6 EventLoopGroup和实现类NioEventLoopGroup

> 通常一个服务端口即一个 ServerSocketChannel对应一个Selector 和一个EventLoop线程。 BossEventLoop 负责接收客户端的连接并将SocketChannel 交给 WorkerEventLoopGroup 来进 行 IO 处理

![image-20220114170600815](https://cdn.wuzx.cool/image-20220114170600815.png)

+ BossEventLoopGroup 通常是一个单线程的 EventLoop，EventLoop 维护着一个注册了ServerSocketChannel 的 Selector 实例，
+ BossEventLoop 不断轮询 Selector 将连接事件分离出来， 通常是 OP_ACCEPT 事件，然后将接收到的 SocketChannel 交给 WorkerEventLoopGroup
+ WorkerEventLoopGroup 会由 next 选择其中一个 EventLoopGroup 来将这个 SocketChannel 注册到其维护的 Selector 并对其后续的 IO 事件进行处理

### 3.2.7  ServerBootstrap和Bootstrap

+ `ServerBootstrap` 是 Netty 中的服务器端启动助手，通过它可以完成服务器端的各种配置；
+ `Bootstrap `是 Netty 中的客户端启动助手，通过它可以完成客户端的各种配置。

> 常用方法
>
> + public ServerBootstrap group(EventLoopGroup parentGroup, EventLoopGroup childGroup)， 该方法用于服务器端，用来设置两个 EventLoop
>
> + public B group(EventLoopGroup group) ，该方法用于客户端，用来设置一个 EventLoop
> + public B channel(Class<? extends C> channelClass)，该方法用来设置一个服务器端的通道 实现
> + public B option(ChannelOption option, T value)，用来给 ServerChannel 添加配置
> + public ServerBootstrap childOption(ChannelOption childOption, T value)，用来给接收到的通道添加配置
> + public ServerBootstrap childHandler(ChannelHandler childHandler)，该方法用来设置业务 处理类（自定义的 handler)
> + public ChannelFuture bind(int inetPort) ，该方法用于服务器端，用来设置占用的端口号
> + public ChannelFuture connect(String inetHost, int inetPort) ，该方法用于客户端，用来连 接服务器端

### 3.2.8 Unpooleda类

> 这是 Netty 提供的一个专门用来操作缓冲区的工具类，常用方法如下所示：
>
> public static ByteBuf copiedBuffer(CharSequence string, Charset charset)，通过给定的数据 和字符编码返回一个 ByteBuf 对象（类似于 NIO 中的 ByteBuffer 对象）

## 3.2 自定义RPC框架

![image-20220113162859055](https://cdn.wuzx.cool/image-20220113162859055.png)

