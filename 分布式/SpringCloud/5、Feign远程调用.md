# **一、Feign**简介

> Feign是*Netflix*开发的一个轻量级**RESTful**的**HTTP**服务客户端(用它来发起请求， 远程调用的)，是以Java接口注解的方式调用Http请求，而不用像Java中通过封装 HTTP请求报文的方式直接调用，Feign被广泛应用在Spring Cloud 的解决方案中。类似于Dubbo，服务消费者拿到服务提供者的接口，然后像调用本地接口方法一样 去调用，实际发出的是远程的请求

+ Feign可帮助我们更加便捷，优雅的调用HTTP API:不需要我们去拼接url然后 呢调用restTemplate的api，在SpringCloud中，使用Feign非常简单，创建一个 接口(在消费者--服务调用方这一端)，并在接口上添加一些注解，代码就完成 了
+ SpringCloud对Feign进行了增强，使Feign支持了SpringMVC注解 (OpenFeign)
+ 本质:封装了**Http**调用流程，更符合面向接口化的编程习惯，类似于**Dubbo**的服务 调用

# 二、**Feign**配置应用

在服务调用者工程(消费)创建接口(添加注解) (效果) **Feign = RestTemplate+Ribbon+Hystrix**

+ 服务消费者工程，添加依赖

``` xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

+ 服务消费者工程 启动类使用注解@EnableFeignClients添加 Feign支持

``` java
@SpringBootApplication
@EnableDiscoveryClient
//@EnableHystrix // 开启Hystrix
//@EnableCircuitBreaker // 开启熔断器
@EnableFeignClients
public class ServiceConsumerApplication {
}
```

+ 创建Feign接口

  ``` java
  /**
   * @FeignClient表明当前类是一个Feign客户端,value指定客户端的服务名称
   */
  @FeignClient(value = "service-producer", fallback = ProducerFeignClientFallback.class, path = "/resume")
  public interface ProducerFeignClient {
      @GetMapping("/openstate/{userId}")
      public Integer findDefaultResumeState(@PathVariable("userId") Long userId);
  }
  ```

  + 1)@FeignClient注解的name属性用于指定要调用的服务提供者名称，和服务 提供者yml文件中spring.application.name保持一致
  + 2)接口中的接口方法，就好比是远程服务提供者Controller中的Hander方法 (只不过如同本地调用了)，那么在进行参数绑定的时，可以使用 @PathVariable、@RequestParam、@RequestHeader等，这也是OpenFeign 对SpringMVC注解的支持，但是需要注意value必须设置，否则会抛出异常

# 三、**Feign**对负载均衡的支持

Feign 本身已经集成了Ribbon依赖和自动配置，因此我们不需要额外引入依赖，可 以通过 ribbon.xx 来进 行全局配置,也可以通过服务名.ribbon.xx 来对指定服务进行 细节配置配置(参考之前，此处略)

Feign默认的请求处理超时时⻓1s，有时候我们的业务确实执行的需要一定时间，那 么这个时候，我们就需要调整请求处理超时时⻓，Feign自己有超时设置，如果配置 Ribbon的超时，则会以Ribbon的为准

## **Ribbon**设置

``` yaml
ribbon:
  # 请求连接超时时间
  ConnectTimeout: 2000
  # 请求处理超时时间
  ReadTimeout: 5000
  # 对所有的操作都进行重试
  OkToRetryOnAllOperations: true
  ####根据如上配置，当访问到故障请求的时候，它会再尝试访问一次当前实例(次数 由MaxAutoRetries配置)，
  ####如果不行，就换一个实例进行访问，如果还不行，再换一次实例访问(更换次数 由MaxAutoRetriesNextServer配置)，
  ####如果依然不行，返回失败信息。
  MaxAutoRetries: 0 #对当前选中实例重试次数，不包括第一次调用
  MaxAutoRetriesNextServer: 0 #切换实例的重试次数
  NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RoundRobinRule #负载策略调整
logging:
  level:
    # Feign日志只会对日志级别为debug的做出响应
    com.wuzx.service.ProducerFeignClient: debug
feign:
  hystrix:
    enabled: true

hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            ##########################################Hystrix的超时时⻓设置
            timeoutInMilliseconds: 15000
```



# 四、**Feign**对熔断器的支持

## 在Feign客户端工程配置文件(application.yml)中开启Feign对熔断器的支持

``` yaml
 # 开启Feign的熔断功能 feign:
  hystrix:
    enabled: true
```

# 五、**Feign**对请求压缩和响应压缩的支持

Feign 支持对请求和响应进行GZIP压缩，以减少通信过程中的性能损耗。通过下面 的参数 即可开启请求与响应的压缩功能:

``` yaml
 
feign:
  compression:
		request:
			enabled: true # 开启请求压缩
			mime-types: text/html,application/xml,application/json # 设置压缩的数据类型，此处也是默认值
			min-request-size: 2048 # 设置触发压缩的大小下限，此处也是默认值
			response:
				enabled: true # 开启响应压缩
```

# 六、**Feign**的日志级别配置

> Feign是http请求客户端，类似于咱们的浏览器，它在请求和接收响应的时候，可以打印出比较详细的一些日志信息(响应头，状态码等等)
>
> 如果我们想看到Feign请求时的日志，我们可以进行配置，默认情况下Feign的日志 没有开启。

## 6.1  开启Feign日志功能及级别

``` java
 
// Feign的日志级别(Feign请求过程信息)
// NONE:默认的，不显示任何日志----性能最好
// BASIC:仅记录请求方法、URL、响应状态码以及执行时间----生产问题追踪
// HEADERS:在BASIC级别的基础上，记录请求和响应的header
// FULL:记录请求和响应的header、body和元数据----适用于开发及测试环境定位问 题
@Configuration
public class FeignConfig {
@Bean
    Logger.Level feignLevel() {
        return Logger.Level.FULL;
} }
```

## 6.2 配置log日志级别为debug

``` yaml
logging:
  level:
    # Feign日志只会对日志级别为debug的做出响应
    com.wuzx.service.ProducerFeignClient: debug
```

