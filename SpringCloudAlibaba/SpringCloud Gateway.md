

![image-20210920215133303](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210920215133303.png)

# 1、什么是网关

> 网关是一个服务，是访问内部系统的唯一入口，提供内部服务的路由中转，额外还可以在此基础上提供`身份认证`、`监控`、`负载均衡`，`限流`、`降级`与`应用检测`等功能

**Spring Cloud Gateway 底层使用了高性能的通信框架Netty**



# 2、Spring Cloud Gateway 与Zuul对比

nginx+lua 高性能反向代理服务器，通常做为负载均衡入口后端

Zuul是第一代网关，spring浏览器

cloud是第二代网关，基于Netty\Reactor\WebFLux构建缓存

- 性能强劲，zuul1.6倍安全
- 功能强大，内置转发，监控，限流等功能

缺点

- 不能再servlet容器下功能，不能使用war包

## 2.1 基础说明

1. spring cloud gateway基于springBoot2.x系列，webflux，reactor等技术，传统的同步库都是不能使用的
2. gateway底层依赖netty,不接受servlet容器或者war包



## 2.2 zuul1.x 与zuul2.x

### ZUUL1.x是基于同步IO

![image-20210920220949412](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210920220949412.png)

### Zuul2.x 基于异步IO

![image-20210920221030249](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210920221030249.png)



# 3、Gateway基本使用

## 3.1predicate 断言

> 参考的是java8的java.util.function.predicate 开发人员可以匹配http请求中的所有内容(例如请求头或请求参数)，如果请求与断言相匹配则进行路由 

![09344R2I-0](/Users/wuzhixuan/Downloads/09344R2I-0.png)



### path断言

``` yaml
predicates:
- path=/mg/**
```

### Query断言

``` yaml
参数值可以写正则，也可以只写参数名
predicates:
- query=foo,ba.
```

### Method断言

``` yaml
predicates:
- Method=get
```

### Host断言

``` yaml
predicates:
- Host=wzx.cool
```

### Cookie断言

``` yaml
predicates:
- cookie=name.wuzhixuan
```



## 3.2 route 路由

> 构建网关的基本模块，它由id,目标uri，一系列的断言和过滤器组成，如果断言为true则匹配该路由
> 


## 3.3filter 过滤

> 指的是spring框架中gatewayfilter的实例，使用过滤器，可以在请求被路由前或者之后对请求进行修改。



## 3.4、总体

- web请求，通过一些匹配条件，定位到真正的服务节点。并在这个转发过程的前后，进行一些精细化控制。
-  predicate就是我们的匹配条件;
-  而filter,就可以理解为一个无所不能的拦截器。有了这两个元素,再加上目标uri,就可以实现一个具体的路由了



# 4、原理

![springcloud gateway概念精讲_springcloud ](https://resource.shangmayuan.com/droxy-blog/2021/09/20/ca97a3364fb5433b8f2ed56f47647b84-2.png)

# 5、通过微服务名实现动态路由

默认情况下gateway会根据注册中心注册的服务列表以注册中心上微服务名为路径创建动态路由进行转发，从而实现动态路由的功能

``` 
server:
  port: 80
spring:
  application:
    name: wuzx-gateway
  profiles:
    active: sit
  cloud:
    nacos:
      discovery:
        server-addr: wuzx.cool:30000

      config:
        server-addr: wuzx.cool:30000
        file-extension: yaml
    gateway:
      discovery:
        locator:
          enabled: true  # 开启从注册中心动态创建路由的功能，利用微服务名进行路由
      loadbalancer:
        retry:
          enabled: true
			routes:

        - id: payment_routh #路由的id，没有固定规则但要求唯一，建议配合服务名
#         uri: http://localhost:8001   #匹配后提供服务的路由地址
          uri: lb://cloud-payment-service
          predicates:
            - path=/payment/get/**   #断言,路径相匹配的进行路由

        - id: payment_routh2
          #uri: http://localhost:8001
          uri: lb://cloud-payment-service
          predicates:
            - path=/payment/lb/**   #断言,路径相匹配的进行路由
```

# 6、自定义过滤器

两个接口介绍：globalfilter，ordered

功能：

-  全局日志记录
-  统一网关鉴权

``` java


/**
 * 鉴权认证
 *
 * @author 吴志旋
 * 自定义filter 需要实现Ordered 和GlobalFilter
 *  Ordered 优先级 越小优先级越大
 */
@Slf4j
@Component
@AllArgsConstructor
public class AuthFilter implements GlobalFilter, Ordered {
	private final AuthProperties authProperties;
	private final ObjectMapper objectMapper;
	private final AntPathMatcher antPathMatcher = new AntPathMatcher();

	@Override
	public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
		String path = exchange.getRequest().getURI().getPath();
		if (isSkip(path)) {
			return chain.filter(exchange);
		}
		ServerHttpResponse resp = exchange.getResponse();
		String headerToken = "";
		String paramToken ="";
		if (StringUtils.isAllBlank(headerToken, paramToken)) {
			return unAuth(resp, "缺失令牌,鉴权失败");
		}
		String auth = StringUtils.isBlank(headerToken) ? paramToken : headerToken;
		String token = JwtUtil.getToken(auth);
		Claims claims = JwtUtil.parseJWT(token);
		if (claims == null) {
			return unAuth(resp, "请求未授权");
		}
		return chain.filter(exchange);
	}

	private boolean isSkip(String path) {
		
	}


	@Override
	public int getOrder() {
		return -100;
	}

}

```

