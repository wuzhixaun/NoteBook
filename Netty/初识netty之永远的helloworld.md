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

# 四、业界使用netty

![image-20211118103248441](https://cdn.wuzx.cool/image-20211118103248441.png)

# 五、搭建永远的 Hello Word

![img](https://pic4.zhimg.com/80/v2-7eefba893a65706eb6bbe4115cbd0b83_720w.jpg)

## 5.1 引入Maven依赖

``` xml
使用的版本是4.1.20，相对比较稳定的一个版本。
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
        <netty-all.version>4.1.20.Final</netty-all.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>io.netty</groupId>
            <artifactId>netty-all</artifactId>
            <version>${netty-all.version}</version>
        </dependency>
    </dependencies>
```

## 5.2代码编写



### 项目结构

```
  netty-helloworld
    ├── client
      ├── Client.class -- 客户端启动类
      ├── ClientHandler.class -- 客户端逻辑处理类
      ├── ClientHandler.class -- 客户端初始化类
    ├── server 
      ├── Server.class -- 服务端启动类
      ├── ServerHandler -- 服务端逻辑处理类
      ├── ServerInitializer -- 服务端初始化类
```

### 服务端代码

```java
/**
 * @author wuzhixuan
 * @version 1.0.0
 * @ClassName Server.java
 * @Description netty 服务端
 * @createTime 2021年11月18日 11:22:00
 */
public class Server {

    public static void main(String[] args) {
        /* 创建两个EventLoopGroup对象*/
        // 创建boss线程组 用于服务端接口客户端的链接
        EventLoopGroup boss = new NioEventLoopGroup();
        // 创建worker线程组，用于客户端的进行SocketChannel数据读写
        EventLoopGroup worker = new NioEventLoopGroup();
        try {


            // 创建 ServerBootstrap 对象,
            ServerBootstrap bootstrap = new ServerBootstrap();

            //设置使用的EventLoopGroup
            bootstrap.group(boss, worker)
                    //设置要被实例化的为 NioServerSocketChannel 类
                    .channel(NioServerSocketChannel.class)
                    // 设置 NioServerSocketChannel 的处理器
                    .handler(new LoggingHandler(LogLevel.INFO))
                    // 设置连入服务端的 Client 的 SocketChannel 的处理器
                    .childHandler(new ServerInitializer());

            // 绑定端口，启动客户端
            final ChannelFuture bind = bootstrap.bind(8888);
            // 监听服务端关闭，并阻塞等待
            bind.channel().closeFuture().sync();


        } catch (InterruptedException e) {
            e.printStackTrace();
        }finally {
            boss.shutdownGracefully();
            worker.shutdownGracefully();
        }

    }
}
```

### 连入服务端的 Client 的 SocketChannel 的处理器

```java
/**
 * @author wuzhixuan
 * @version 1.0.0
 * @ClassName ServerInitializer.java
 * @Description 连入服务端的 Client 的 SocketChannel 的处理器
 * @createTime 2021年11月18日 11:41:00
 */
public class ServerInitializer extends ChannelInitializer<SocketChannel> {
    private static final StringDecoder DECODER = new StringDecoder();
    private static final StringEncoder ENCODER = new StringEncoder();

    private static final ServerHandler SERVER_HANDLER = new ServerHandler();

    @Override
    protected void initChannel(SocketChannel socketChannel) throws Exception {
        final ChannelPipeline pipeline = socketChannel.pipeline();

        // 添加帧限定符来防止粘包现象
        pipeline.addLast(new DelimiterBasedFrameDecoder(8192, Delimiters.lineDelimiter()));
        pipeline.addLast(DECODER);
        pipeline.addLast(ENCODER);

        // 业务逻辑实现类
        pipeline.addLast(SERVER_HANDLER);

    }
}
```



### 服务端具体业务逻辑

```java
/**
 * @author wuzhixuan
 * @version 1.0.0
 * @ClassName ServerHandler.java
 * @Description TODO
 * @createTime 2021年11月18日 11:48:00
 *
 * 使用Netty编写业务层的代码，我们需要继承ChannelInboundHandlerAdapter 或SimpleChannelInboundHandler类，
 * 在这里顺便说下它们两的区别吧。
 * 1.继承SimpleChannelInboundHandler类之后，会在接收到数据后会自动release掉数据占用的Bytebuffer资源。并且继承该类需要指定数据格式。
 * 2.继承ChannelInboundHandlerAdapter则不会自动释放，需要手动调用ReferenceCountUtil.release()等方法进行释放。继承该类不需要指定数据格式。
 * 个人推荐服务端继承ChannelInboundHandlerAdapter，手动进行释放，防止数据未处理完就自动释放了。而且服务端可能有多个客户端进行连接，并且每一个客户端请求的数据格式都不一致，这时便可以进行相应的处理。
 * 客户端根据情况可以继承SimpleChannelInboundHandler类。好处是直接指定好传输的数据格式，就不需要再进行格式的转换了
 */
public class ServerHandler extends SimpleChannelInboundHandler<String> {


    /**
     * 建立连接时，发送一条庆祝消息
     *
     * @param ctx
     * @throws Exception
     */
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        ctx.write("Welcome to " + InetAddress.getLocalHost().getHostName() + "!\r\n");
        ctx.write("It is " + new Date() + " now.\r\n");
        ctx.flush();

    }

    /**
     * 业务逻辑处理
     * @param ctx
     * @param request
     * @throws Exception
     */
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, String request) throws Exception {
        String response;
        boolean close = false;
        if (request.isEmpty()) {
            response = "Please type something.\r\n";
        } else if ("bye".equals(request.toLowerCase())) {
            response = "Have a good day!\r\n";
            close = true;
        } else {
            response = "Did you say '" + request + "'?\r\n";
        }

        ChannelFuture future = ctx.write(response);

        if (close) {
            future.addListener(ChannelFutureListener.CLOSE);
        }
    }

    /**
     * 异常处理
     * @param ctx
     * @param cause
     * @throws Exception
     */
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        cause.printStackTrace();
        ctx.close();
    }

    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
        ctx.flush();
    }
}
```

## 客户端



### 客户端主类

```java
/**
 * @author wuzhixuan
 * @version 1.0.0
 * @ClassName Client.java
 * @Description 客户端代码实现
 * @createTime 2021年11月18日 11:56:00
 */
public class Client {


    public static void main(String[] args) {
        EventLoopGroup group = new NioEventLoopGroup();

        try {
            Bootstrap bootstrap = new Bootstrap();
            bootstrap.group(group)
                    .channel(NioSocketChannel.class)
                    .handler(new ClientInitializer());

            Channel ch = bootstrap.connect("127.0.0.1",8888).sync().channel();


            ChannelFuture lastWriteFuture = null;
            BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
            for (;;) {
                String line = in.readLine();
                if (line == null) {
                    break;
                }

                // Sends the received line to the server.
                lastWriteFuture = ch.writeAndFlush(line + "\r\n");

                // If user typed the 'bye' command, wait until the server closes
                // the connection.
                if ("bye".equals(line.toLowerCase())) {
                    ch.closeFuture().sync();
                    break;
                }
            }
            // Wait until all messages are flushed before closing the channel.
            if (lastWriteFuture != null) {
                lastWriteFuture.sync();
            }
        } catch (InterruptedException | IOException e) {
            e.printStackTrace();
        } finally {
            group.shutdownGracefully();
        }
        
    }
}
```

```java
/**
 * @author wuzhixuan
 * @version 1.0.0
 * @ClassName ClientHandler.java
 * @Description TODO
 * @createTime 2021年11月18日 14:12:00
 */
public class ClientHandler extends SimpleChannelInboundHandler<String> {


    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, String msg) throws Exception {
        System.err.println(msg);
    }

    //异常数据捕获
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        cause.printStackTrace();
        ctx.close();
    }

}
```

```java
/**
 * @author wuzhixuan
 * @version 1.0.0
 * @ClassName ClientInitializer.java
 * @Description TODO
 * @createTime 2021年11月18日 14:10:00
 */
public class ClientInitializer extends ChannelInitializer<SocketChannel> {

    private static final StringDecoder DECODER = new StringDecoder();
    private static final StringEncoder ENCODER = new StringEncoder();

    private static final ClientHandler CLIENT_HANDLER = new ClientHandler();
    @Override
    protected void initChannel(SocketChannel socketChannel) throws Exception {
        ChannelPipeline pipeline = socketChannel.pipeline();
        pipeline.addLast(new DelimiterBasedFrameDecoder(8192, Delimiters.lineDelimiter()));
        pipeline.addLast(DECODER);
        pipeline.addLast(ENCODER);

        pipeline.addLast(CLIENT_HANDLER);
    }
}
```

到这里netty就简单搭建完成了

### 服务端输出

``` txt
十一月 18, 2021 2:15:23 下午 io.netty.handler.logging.LoggingHandler channelRegistered
信息: [id: 0x54ec564b] REGISTERED
十一月 18, 2021 2:15:24 下午 io.netty.handler.logging.LoggingHandler bind
信息: [id: 0x54ec564b] BIND: 0.0.0.0/0.0.0.0:8888
十一月 18, 2021 2:15:24 下午 io.netty.handler.logging.LoggingHandler channelActive
信息: [id: 0x54ec564b, L:/0:0:0:0:0:0:0:0:8888] ACTIVE
十一月 18, 2021 2:15:35 下午 io.netty.handler.logging.LoggingHandler channelRead
信息: [id: 0x54ec564b, L:/0:0:0:0:0:0:0:0:8888] RECEIVED: [id: 0xb0450fea, L:/127.0.0.1:8888 - R:/127.0.0.1:50272]
```



### 客户端输出

``` txt
Connected to the target VM, address: '127.0.0.1:50101', transport: 'socket'
Welcome to WuZhiXuan!
It is Thu Nov 18 14:15:35 CST 2021 now.
hello
Did you say 'hello'?
Please type something.
Please type something.
s
Did you say 's'?

Please type something.
sad
Did you say 'sad'?
asd
Did you say 'asd'?
s
Did you say 's'?

```

