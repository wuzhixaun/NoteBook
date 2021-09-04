Sentinel的理念是只需要开发者关注资源的定义，它默认会对资源进行流控。当然，我们还是需要对定义的资源设置流控规则，主要有两种方式：

- 通过FlowRuleManager.loadRules()手动加载流控规则。
- 在Sentinel Dashboard上针对资源动态创建流控规则。

针对第一种方式，如果接入Sentinel Dashboard，那么同样支持动态修改流控规则，但是基于Sentinel Dashboard所配置的流控规则，都是保存在内存中的，一旦应用重启，这些规则都会被清除。为了解决这个问题，Sentinel提供了动态数据源支持。

目前，Sentinel支持Consul、Zookeeper、Redis、Nacos、Apollo、etcd等数据源的扩展，接下来通过一个案例展示Spring Cloud Sentinel集成Nacos实现动态流控规则，步骤如下：

# 应用配置

**第一步**：在Spring Cloud应用的`pom.xml`中引入Spring Cloud Alibaba的Sentinel模块和Nacos存储扩展：

```java
    <dependencies> 
        <!-- https://mvnrepository.com/artifact/com.alibaba.cloud/spring-cloud-starter-alibaba-sentinel -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
            <version>2021.1</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/com.alibaba.csp/sentinel-datasource-nacos -->
        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-datasource-nacos</artifactId>
            <version>1.8.2</version>
        </dependency>
    </dependencies
```

**第二步**：在Spring Cloud应用中添加配置信息：

``` yaml
server:
  port: 8080
spring:
  application:
    name: spring-cloud-alibaba
  cloud:
    sentinel:
      transport:
        dashboard: sentinel:8080
      eager: true #服务注启动，直接注册到dashboard
      datasource:
        ds:
          nacos:
            server-addr: nacos-headless:8848
            dataId: my-sentinel
            groupId: DEFAULT_GROUP #nacos中存储规则的groupId
            rule-type: flow #定义存储的规则类型,该参数是spring cloud alibaba升级到0.2.2之后增加的配置
            data-type: json
```

- `spring.cloud.sentinel.transport.dashboard`：sentinel dashboard的访问地址，根据上面准备工作中启动的实例配置
- `spring.cloud.sentinel.datasource.ds.nacos.server-addr`：nacos的访问地址，，根据上面准备工作中启动的实例配置
- `spring.cloud.sentinel.datasource.ds.nacos.groupId`：nacos中存储规则的groupId
- `spring.cloud.sentinel.datasource.ds.nacos.dataId`：nacos中存储规则的dataId

**注意**：Spring Cloud Alibaba的Sentinel整合文档中有一些小问题，比如：并没有`spring.cloud.sentinel.datasource.ds2.nacos.rule-type`这个参数。可能是由于版本迭代更新，文档失修的缘故。读者在使用的时候，可以通过查看`org.springframework.cloud.alibaba.sentinel.datasource.config.DataSourcePropertiesConfiguration`和`org.springframework.cloud.alibaba.sentinel.datasource.config.NacosDataSourceProperties`两个类来分析具体的配置内容，会更为准确。

**第三步**：创建应用主类

```
@RestController
@RequestMapping("/sentinel")
public class SentinelController {


    @Autowired
    private SentinelService sentinelService;

    @GetMapping("/get")
    public String get() {
        return sentinelService.getBody();
    }
}

@Service
public class SentinelService {


    @SentinelResource(value = "get",blockHandler = "getBodyBack")
    public String getBody() {
        // 真正的业务逻辑
        // 被保护的资源
        return "给你我的肉体哦";
    }


    public String getBodyBack(BlockException blockException) {
        return "降级了";
    }
}
```



**第四步**：Nacos中创建限流规则的配置，比如：

![image-20210905002003434](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210905002003434.png)

其中：`Data ID`、`Group`就是上面**第二步**中配置的内容。配置格式选择JSON，并在配置内容中填入下面的内容：

```json
[
    {
        "resource": "get",
        "limitApp": "default",
        "grade": 1,
        "count": 1,
        "strategy": 0,
        "controlBehavior": 0,
        "clusterMode": false
    }
]
```

可以看到上面配置规则是一个数组类型，数组中的每个对象是针对每一个保护资源的配置对象，每个对象中的属性解释如下：

- resource：资源名，即限流规则的作用对象
- limitApp：流控针对的调用来源，若为 default 则不区分调用来源
- grade：限流阈值类型（QPS 或并发线程数）；`0`代表根据并发数量来限流，`1`代表根据QPS来进行流量控制
- count：限流阈值
- strategy：调用关系限流策略
- controlBehavior：流量控制效果（直接拒绝、Warm Up、匀速排队）
- clusterMode：是否为集群模式

**第五步**：启动应用



此时，在Sentinel Dashboard中就可以看到当前我们启动的`alibaba-sentinel-datasource-nacos`服务。点击左侧菜单中的流控规则，可以看到已经存在一条记录了



# 注意

Sentinel控制台不具备同步修改Nacos配置的能力，而Nacos由于可以通过在客户端中使用Listener来实现自动更新。所以，在整合了Nacos做规则存储之后，需要知道在下面两个地方修改存在不同的效果：

- Sentinel控制台中修改规则：仅存在于服务的内存中，不会修改Nacos中的配置值，重启后恢复原来的值。
- Nacos控制台中修改规则：服务的内存中规则会更新，Nacos中持久化规则也会更新，重启后依然保持。