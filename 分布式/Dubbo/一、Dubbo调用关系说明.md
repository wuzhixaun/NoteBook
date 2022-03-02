# 1、Dubbo调用关系说明

![image-20220303002136101](https://cdn.wuzx.cool/image-20220303002136101.png)

## provide 暴露服务的服务提供者

+ protocol 负责提供者和消费者指尖协议交互数据
+ Service 真实的业务服务信息，可以理解成接口和实现
+ Container Dubbo的运行环境

## Consumer 调用远程服务的服务消费方

+ Protocol 负责消费者和服务提供者协议交互数据
+ Cluster 感知提供者端的列表信息
+ Proxy 可以理解成提供者的服务调用代理类 由它接管Consumer的接口调用逻辑

## 启动和执行流程说明

+ 提供者启动，者Container`容器负责把`Service`信息加载并通过Protocol注册到注册中心`Registry`
+ 消费者端启动，通过监听提供者列表来感知提供者信息，并在提供者发生改变时，通过注册中心及时通知消费端
+ 消费者发起请求，通过Proxy模块
+ 利用Cluster模块，来选择真实的要发送给的提供者信息
+ 交由Consumer的Protocol把信息发送给提供者
+ 提供者通过Protocol 处理消费者的信息
+ 最后由真正的服务提供者Service来进行处理

# 2、Dubbo整体调用链路

![image-20220303004407193](https://cdn.wuzx.cool/image-20220303004407193.png)

## 整体链路调用的流程:

1. 消费者通过Interface进行方法调用 统一交由消费者端的 Proxy 通过ProxyFactory 来进行代理 对象的创建 使用到了 jdk javassist技术
2. 交给Filter 这个模块 做一个统一的过滤请求 在SPI案例中涉及过 
3. 接下来会进入最主要的Invoker调用逻辑
   1. 通过Directory 去配置中新读取信息 最终通过list方法获取所有的Invoker 
   2. 通过Cluster模块 根据选择的具体路由规则 来选取Invoker列表 
   3. 通过LoadBalance模块 根据负载均衡策略 选择一个具体的Invoker 来处理我们的请求 如果执行中出现错误 并且Consumer阶段配置了重试机制 则会重新尝试执行

4. 继续经过Filter 进行执行功能的前后封装 Invoker 选择具体的执行协议 
5. 客户端 进行编码和序列化 然后发送数据
6.  到达Consumer中的 Server 在这里进行 反编码 和 反序列化的接收数据 
7. 使用Exporter选择执行器
8. 交给Filter 进行一个提供者端的过滤 到达 Invoker 执行器 9. 通过Invoker 调用接口的具体实现 然后返回