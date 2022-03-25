![zipkin](https://cdn.wuzx.cool/zipkin.png)

# 一、分布式链路追踪技术适用场景(问题场景)

> 为了支撑日益增⻓的庞大业务量，我们会使用微服务架构设计我们的系统，使得我们的系统不仅能够通过集群部署抵挡流量的冲击，又能根据业务进行灵活的扩展。
> 那么，在微服务架构下，一次请求少则经过三四次服务调用完成，多则跨越几十个甚至是上百个服务节点。那么问题接踵而来:
>
> + 1)如何动态展示服务的调用链路?(比如A服务调用了哪些其他的服务---依赖 关系)
> + 2)如何分析服务调用链路中的瓶颈节点并对其进行调优?(比如A—>B—>C，C 服务处理时间特别⻓)
> + 3)如何快速进行服务链路的故障发现?

##  分布式链路追踪技术

> 如果我们在一个请求的调用处理过程中，在各个链路节点都能够记录下日志，并 最终将日志进行集中可视化展示，那么我们想监控调用链路中的一些指标就有希 望了~~~比如，请求到达哪个服务实例?请求被处理的状态怎样?处理耗时怎 样?这些都能够分析出来了...

## 市场上的分布式链路追踪方案

分布式链路追踪技术已然成熟，产品也不少，国内外都有，比如

+ Spring Cloud Sleuth + Twitter Zipkin 阿里巴巴的“鹰眼”
+  大众点评的“CAT”
+  美团的“Mtrace”
+ 京东的“Hydra”
+  新浪的“Watchman” 
+ 另外还有最近也被提到很多的Apache Skywalking。

# 二、分布式链路追踪技术核心思想

本质:记录日志，作为一个完整的技术，分布式链路追踪也有自己的理论和概念

![image-20220326011729035](https://cdn.wuzx.cool/image-20220326011729035.png)

> 一个请求通过网关服务路由到下游的微服务-1， 然后微服务-1调用微服务-2，拿到结果后再调用微服务-3，最后组合微服务-2和微服 务-3的结果，通过网关返回给用户

**当下主流的的分布式链路追踪技术/系统所基于的理念都来自于Google 的一篇论文《Dapper, a Large-Scale Distributed Systems Tracing Infrastructure》**

上图标识一个请求链路，一条链路通过TraceId唯一标识，span标识发起的请求信 息，各span通过parrentId关联起来

+ **Trace**:服务追踪的追踪单元是从客户发起请求(request)抵达被追踪系统的边界开始，到被追踪系统向客户返回响应(response)为止的过程

+ **Trace ID**:为了实现请求跟踪，当请求发送到分布式系统的入口端点时，只需要服 务跟踪框架为该请求创建一个唯一的跟踪标识Trace ID，同时在分布式系统内部流转 的时候，框架失踪保持该唯一标识，直到返回给请求方一个Trace由一个或者多个Span组成，每一个Span都有一个SpanId，Span中会记录 TraceId，同时还有一个叫做ParentId，指向了另外一个Span的SpanId，表明父子 关系，其实本质表达了依赖关系

+ **Span ID**:为了统计各处理单元的时间延迟，当请求到达各个服务组件时，也是通过 一个唯一标识Span ID来标记它的开始，具体过程以及结束。对每一个Span来说， 它必须有开始和结束两个节点，通过记录开始Span和结束Span的时间戳，就能统计 出该Span的时间延迟，除了时间戳记录之外，它还可以包含一些其他元数据，比如 时间名称、请求信息等。

> 每一个Span都会有一个唯一跟踪标识 Span ID,若干个有序的 span 就组成了一个 trace。Span可以认为是一个日志数据结构，在一些特殊的时机点会记录了一些日志信息， 比如有时间戳、spanId、TraceId，parentIde等，Span中也抽象出了另外一个概 念，叫做事件，核心事件如下
>
> + CS :client send/start 客户端/消费者发出一个请求，描述的是一个span开始 
> + SR: server received/start 服务端/生产者接收请求 SR-CS属于请求发送的网络延 迟
> + SS: server send/finish 服务端/生产者发送应答 SS-SR属于服务端消耗时间 
> + CR:client received/finished 客户端/消费者接收应答 CR-SS表示回复需要的时 间(响应的网络延迟)

Spring Cloud Sleuth (追踪服务框架)可以追踪服务之间的调用，Sleuth可以记录 一个服务请求经过哪些服务、服务处理时⻓等，根据这些，我们能够理清各微服务 间的调用关系及进行问题追踪分析。

+ 耗时分析:通过 Sleuth 了解采样请求的耗时，分析服务性能问题(哪些服务调 用比较耗时)
+ 链路优化:发现频繁调用的服务，针对性优化等 Sleuth就是通过记录日志的方式来记录踪迹数据的

**我们往往把Spring Cloud Sleuth 和 Zipkin 一起使用，把 Sleuth 的数据信 息发送给 Zipkin 进行聚合，利用 Zipkin 存储并展示数据。**

# 三、**Sleuth + Zipkin**应用

## 3.1 每一个需要被追踪踪迹的微服务工程都引入依赖坐标

``` xml
        <!--链路追踪-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-sleuth</artifactId>
        </dependency>
```

## 3.2 修改application.yml配置文件，添加日志级别

``` yaml
#分布式链路追踪 logging:
logging:
  level:
    org.springframework.web.servlet.DispatcherServlet: debug
    org.springframework.cloud.sleuth: debug
```

这样的日志首先不容易阅读观察，另外日志分散在各个微服务服务器上，接下来我 们使用zipkin统一聚合轨迹日志并进行存储展示

## 3.3 结合 Zipkin 展示追踪数据

Zipkin 包括Zipkin Server和 Zipkin Client两部分，Zipkin Server是一个单独的服务，Zipkin Client就是具体的微服务

### 搭建Zipkin Server 构建

+ 创建 zipkin-server 服务,引用依赖

  ``` xml
  <?xml version="1.0" encoding="UTF-8"?>
  <project xmlns="http://maven.apache.org/POM/4.0.0"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
      <parent>
          <artifactId>springcloud-parent</artifactId>
          <groupId>com.wuzx</groupId>
          <version>1.0-SNAPSHOT</version>
      </parent>
      <modelVersion>4.0.0</modelVersion>
  
      <artifactId>zipkin-server</artifactId>
  
      <properties>
          <maven.compiler.source>11</maven.compiler.source>
          <maven.compiler.target>11</maven.compiler.target>
      </properties>
  
      <dependencies>
          <!--zipkin-server的依赖坐标-->
          <dependency>
              <groupId>io.zipkin.java</groupId>
              <artifactId>zipkin-server</artifactId>
              <version>2.12.3</version>
              <exclusions>
                  <!--排除掉log4j2的传递依赖，避免和springboot依赖的日志组件冲突-->
                  <exclusion>
                      <groupId>org.springframework.boot</groupId>
                      <artifactId>spring-boot-starter-log4j2</artifactId>
                  </exclusion>
              </exclusions>
          </dependency>
  
          <!--zipkin-server ui界面依赖坐标-->
          <dependency>
              <groupId>io.zipkin.java</groupId>
              <artifactId>zipkin-autoconfigure-ui</artifactId>
              <version>2.12.3</version>
          </dependency>
      </dependencies>
  
  </project>
  ```

+ 启动类,@EnableZipkinServer开启zipkin sever

  ``` java
  @SpringBootApplication
  @EnableZipkinServer
  public class ZipKinServerApplication {
  
      public static void main(String[] args) {
          SpringApplication.run(ZipKinServerApplication.class, args);
      }
  }
  ```

+ 配置文件 application.yml

  ``` yaml
  server:
    port: 9411
  management:
    metrics:
      web:
        server:
          auto-time-requests: false # 关闭自动检测
  ```

  

## Zipkin Client 构建

+ pom中添加 zipkin 依赖

  ``` xml
  <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-zipkin</artifactId>
  </dependency>
  ```

+ application.yml 中添加对zipkin server的引用

  ``` yaml
  spring:
    application:
      name: gateway
    zipkin:
      base-url: http://localhost:9411 # zipkin server的请求地址
      sender:
        type: web  # web 客户端将踪迹日志数据通过网络请求的方式传送到服务端 # kafka/rabbit 客户端将踪迹日志数据传递到mq进行中转
    sleuth:
      sampler:
        # # 采样率 1 代表100%全部采集 ，默认0.1 代表10% 的请求踪迹数据会被采
        #集
        ## 生产环境下，请求量非常大，没有必要所有请求的踪迹数据都采集分析，对
        #于网络包括server端压力都是比较大的，可以配置采样率采集一定比例的请求的踪迹 数据进行分析即可
        probability: 1
  ```

  

