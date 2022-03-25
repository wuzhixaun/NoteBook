# 一、分布式配置中心应用场景

> 单体应用架构，配置信息的管理、维护并不会显得特别麻烦，手动操作就可以，因为就一个工程;
>
> 微服务架构，因为我们的分布式集群环境中可能有很多个微服务，我们不可能一个 一个去修改配置然后重启生效，在一定场景下我们还需要在运行期间动态调整配置 信息，比如:根据各个微服务的负载情况，动态调整数据源连接池大小，我们希望 配置内容发生变化的时候，微服务可以自动更新。

场景总结如下:

+ 1)集中配置管理，一个微服务架构中可能有成百上千个微服务，所以集中配置管理 是很重要的(一次修改、到处生效)

+ 2)不同环境不同配置，比如数据源配置在不同环境(开发dev,测试test,生产prod) 中是不同的

+ 3)运行期间可动态调整。例如，可根据各个微服务的负载情况，动态调整数据源连 接池大小等配置修改后可自动更新

+ 4)如配置内容发生变化，微服务可以自动更新配置 

  

  **那么，我们就需要对配置文件进行集中式管理，这也是分布式配置中心的作用。**

# 二、Config简介

Spring Cloud Config是一个分布式配置管理方案，包含了 Server端和 Client端两个 部分。

![image-20220324011625719](https://cdn.wuzx.cool/image-20220324011625719.png)

+ Server 端:提供配置文件的存储、以接口的形式将配置文件的内容提供出去， 通过使用@EnableConfigServer注解在 Spring boot 应用中非常简单的嵌入
+ Client 端:通过接口获取配置数据并初始化自己的应用

# 三、Config分布式配置应用

> **Config Server**是集中式的配置服务，用于集中管理应用程序各个环境下的配置。 默认使用**Git**存储配置文件内容，也可以**SVN**

springcloud config 的URL与配置文件的映射关系如下:

``` yaml
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

## 构建**Config Server**统一配置中心

### 引入依赖坐标

``` xml
    <!--eureka client 客户端依赖引入-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <!--config配置中心服务端-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-amqp</artifactId>
        </dependency>
```

### 配置启动注解

配置启动类，使用注解@EnableConfigServer开启配置中心服务器功能

``` java
@SpringBootApplication
@EnableDiscoveryClient
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

### 配置文件

``` yaml
server:
  port: 8888

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


# springboot中暴露健康检查等断点接口
management:
  endpoints:
    web:
      exposure:
        include: "*"

  endpoint:
    # 暴露健康接口的细节 endpoint:
    health:
      show-details: always
spring:
  application:
    name: config-server
  rabbitmq:
    host: 127.0.0.1
    port: 5672
    username: guest
    password: guest
  cloud:
    config:
      server:
        git:
          uri: https://gitee.com/wuzhixuan/config-server-repo.git
          username: ******
          password: *******
          search-paths:
            - config-server-repo
      # 读取分支
      label: master

```

### **Client**客户端,添加依赖坐标

``` yaml
        <!--引入config-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-client</artifactId>
        </dependency>
```

### **application.yml**修改为**bootstrap.yml**配置文件

> bootstrap.yml是系统级别的，优先级比application.yml高，应用启动时会检查这个 配置文件，在这个配置文件中指定配置中心的服务地址，会自动拉取所有应用配置 并且启用。

# 四、 Config配置自动更新

在微服务架构中，我们可以结合消息总线(Bus)实现分布式配置的自动更新 (Spring Cloud Config+Spring Cloud Bus)

## 4.1 消息总线**Bus**

所谓消息总线Bus，即我们经常会使用MQ消息代理构建一个共用的Topic，通过这个 Topic连接各个微服务实例，MQ广播的消息会被所有在注册中心的微服务实例监听 和消费。换言之就是通过一个主题连接各个微服务，打通脉络。

![image-20220324012646586](https://cdn.wuzx.cool/image-20220324012646586.png)

## 4.2 **Spring Cloud Config+Spring Cloud Bus** 实现自动刷新

> MQ消息代理，我们还选择使用RabbitMQ，ConfigServer和ConfigClient都添加都消息总线的支持以及与RabbitMq的连接信息

### Config Server服务端添加消息总线支持

``` xml
 
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bus-amqp</artifactId>
</dependency>
```

### ConfigServer添加配置

``` yaml
 
spring:
  rabbitmq:
    host: 127.0.0.1
    port: 5672
    username: guest
    password: guest
```

### 3)微服务暴露端口

``` xml
 
management:
  endpoints:
    web:
      exposure:
        include: bus-refresh
建议暴露所有的端口
management:
  endpoints:
    web:
      exposure:
				include: "*"
```

### 4)重启各个服务，更改配置之后，向配置中心服务端发送post请求http://localhost:9003/actuator/bus-refresh，各个客户端配置即可自动刷新

### 5 即为最后面跟上要定向刷新的实例的 服务名**:**端口号即可

