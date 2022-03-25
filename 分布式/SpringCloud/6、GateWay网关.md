

![](https://cdn.wuzx.cool/src=http___pic4.zhimg.com_v2-3bf0384145910d587f6a8fad3198bf77_180x120.jpg&refer=http___pic4.zhimg%20(1).webp)

# 一、**GateWay**简介

> Spring Cloud GateWay是Spring Cloud的一个全新项目，目标是取代Netflix Zuul， 它基于Spring5.0+SpringBoot2.0+WebFlux(基于高性能的Reactor模式响应式通信 框架Netty，异步非阻塞模型)等技术开发，性能高于Zuul，官方测试，GateWay是 Zuul的1.6倍，旨在为微服务架构提供一种简单有效的统一的API路由管理方式。
>
> Spring Cloud GateWay不仅提供统一的路由方式(反向代理)并且基于 Filter(定义 过滤器对请求过滤，完成一些功能) 链的方式提供了网关基本的功能，例如:鉴权、 流量控制、熔断、路径重写、日志监控等

![image-20220323000708948](https://cdn.wuzx.cool/image-20220323000708948.png)

# 二、**GateWay**核心概念

> Zuul1.x 阻塞式IO 2.x 基于Netty
>  Spring Cloud GateWay天生就是异步非阻塞的，基于Reactor模型
>
> 一个请求—>网关根据一定的条件匹配—匹配成功之后可以将请求转发到指定的服务 地址;而在这个过程中，我们可以进行一些比较具体的控制(限流、日志、黑白名 单)

+ 路由(route): 网关最基础的部分，也是网关比较基础的工作单元。路由由一 个ID、一个目标URL(最终路由到的地址)、一系列的断言(匹配条件判断)和 Filter过滤器(精细化控制)组成。如果断言为true，则匹配该路由。
+ 断言(predicates):参考了Java8中的断言java.util.function.Predicate，开发 人员可以匹配Http请求中的所有内容(包括请求头、请求参数等)(类似于 nginx中的location匹配一样)，如果断言与请求相匹配则路由。
+ 过滤器(filter):一个标准的Spring webFilter，使用过滤器，可以在请求之前 或者之后执行业务逻辑。

![image-20220323000822964](https://cdn.wuzx.cool/image-20220323000822964.png)

# 三、**GateWay**工作过程

![image-20220323000845650](https://cdn.wuzx.cool/image-20220323000845650.png)

客户端向Spring Cloud GateWay发出请求，然后在`GateWay Handler Mapping`中 找到与请求相匹配的路由，将其发送到`GateWay Web Handler`;Handler再通过指 定的过滤器链来将请求发送到我们实际的服务执行业务逻辑，然后返回。过滤器之 间用虚线分开是因为过滤器可能会在发送代理请求之前(pre)或者之后(post)执 行业务逻辑。

Filter在“pre”类型过滤器中可以做参数校验、权限校验、流量监控、日志输出、协议 转换等，在“post”类型的过滤器中可以做响应内容、响应头的修改、日志的输出、流 量监控等。

**GateWay核心逻辑:路由转发+执行过滤器链**

# 四、**GateWay**应用

## 4.1创建工程gateway

> GateWay不需要使用web模块，它引入的是WebFlux(类似于SpringMVC)

``` xml
<dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-commons</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-
client</artifactId>
        </dependency>
<!--GateWay 网关--> <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-
gateway</artifactId>
        </dependency>
<!--引入webflux-->
   
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
<!--日志依赖--> <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-logging</artifactId>
</dependency>

    </dependencies>
```

注意:不要引入**starter-web**模块，需要引入**web-flux**

## 4.2 application.yml 配置文件

``` yaml
server:
  port: 9002

#注册到Eureka服务中心
eureka:
  client:
    service-url:
      # 注册到集群，就把多个Eurekaserver地址使用逗号连接起来即可；注册到单实例（非集群模式），那就写一个就ok
      defaultZone: http://localhost:8060/eureka
  instance:
    prefer-ip-address: true # 服务实例显示ip而不是显示主机名
    # 实例名称
    instance-id: ${spring.cloud.client.ip-address}:${spring.application.name}:${server.port}:@project.version@

spring:
  application:
    name: gateway
  cloud:
    gateway:
      routes: # 路由可以有多个
        - id: service-autodeliver-router # 我们自定义的路由 ID，保 持唯一
#          uri: http://127.0.0.1:8090 # 目标服务地址 自动投递微服务 (部署多实例) 动态路由:uri配置的应该是一个服务名称，而不应该是一个具体的 服务实例的地址
          uri: lb://service-consumer
          # gateway网关从服务注册中心获取实例信息然后负载后路由
          predicates:
            - Path=/autodeliver/**
          filters:
            - StripPrefix=1
        - id: service-resume-router
#          uri: http://127.0.0.1:8080
          uri: lb://service-producer
          predicates:
            - Path=/resume/**
          filters:
            - StripPrefix=1
```

## 4.3 **GateWay**动态路由详解

> GateWay支持自动从注册中心中获取服务列表并访问，即所谓的动态路由

+ 1)pom.xml中添加注册中心客户端依赖(因为要获取注册中心服务列表，eureka 客户端已经引入)
+ 2)动态路由配置

![image-20220323003738660](https://cdn.wuzx.cool/image-20220323003738660.png)

# 五、**GateWay**过滤器

## 5.1 **GateWay**过滤器简介

> 从过滤器生命周期(影响时机点)的⻆度来说，主要有两个pre和post:
>
> `pre`:这种过滤器在请求被路由之前调用。我们可利用这种过滤器实现身份 验证、在集群中选择 请求的微服务、记录调试信息等。
>
> `post`:这种过滤器在路由到微服务以后执行。这种过滤器可用来为响应添加 标准的 HTTP Header、收集统计信息和指标、将响应从微服务发送给 客户端等。

从过滤器类型的⻆度，Spring Cloud GateWay的过滤器分为GateWayFilter和 GlobalFilter两种

![image-20220323003920663](https://cdn.wuzx.cool/image-20220323003920663.png)

如Gateway Filter可以去掉url中的占位后转发路由，比如

``` yaml
 
predicates:
        - Path=/resume/**
				filters:
					- StripPrefix=1 # 可以去掉resume之后转发
```

## **5.2** 自定义全局过滤器实现**IP**访问限制(黑白名单)

``` java
package com.wuzx.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;


/**
 * 定义全局过滤器，会对所有路由生效 */

@Slf4j
@Component
public class BlackListFilter implements GlobalFilter, Ordered {


    private static List<String> blackList = new ArrayList<>();
    static {
        blackList.add("0:0:0:0:0:0:0:1"); // 模拟本机地址
    }


    /**
     * 过滤器核心方法
     * @param exchange 封装了request和response对象的上下文
     * @param chain 网关过滤器链(包含全局过滤器和单路由过滤器)
     * @return
     */
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 从上下文中取出request和response对象
        ServerHttpRequest request = exchange.getRequest();
        ServerHttpResponse response = exchange.getResponse();

        // 从request对象中获取客户端ip
        String clientIp = request.getRemoteAddress().getHostString();

        // 拿着clientIp去黑名单中查询，存在的话就决绝访问
        if (blackList.contains(clientIp)) {
            String data = "Request be denied!";
            DataBuffer wrap = response.bufferFactory().wrap(data.getBytes());
            return response.writeWith(Mono.just(wrap));
        }

        // 合法请求，放行，执行后续的过滤器
        return chain.filter(exchange);
    }

    /**
     * 返回值表示当前过滤器的顺序(优先级)，数值越小，优先级越高
     * @return
     */
    @Override
    public int getOrder() {
        return 0;
    }
}

```

