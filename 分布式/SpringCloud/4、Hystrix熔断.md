# 一、**Hystrix**简介

> Hystrix(豪猪----->刺)，宣言“defend your app”是由Netflix开源的一个 延迟和容错库，用于隔离访问远程系统、服务或者第三方库，防止级联失败，从而 提升系统的可用性与容错性。Hystrix主要通过以下几点实现延迟和容错。

+ 包裹请求:使用HystrixCommand包裹对依赖的调用逻辑。 自动投递微服务方 法(@HystrixCommand 添加Hystrix控制) ——调用简历微服务 
+ 跳闸机制:当某服务的错误率超过一定的阈值时，Hystrix可以跳闸，停止请求 该服务一段时间。 
+ 资源隔离:Hystrix为每个依赖都维护了一个小型的线程池(舱壁模式)(或者信号 量)。如果该线程池已满， 发往该依赖的请求就被立即拒绝，而不是排队等 待，从而加速失败判定。 监控:Hystrix可以近乎实时地监控运行指标和配置的变化，例如成功、失败、 超时、以及被拒绝 的请求等。
+  回退机制:当请求失败、超时、被拒绝，或当断路器打开时，执行回退逻辑。回 退逻辑由开发人员 自行提供，例如返回一个缺省值。 
+ 自我修复:断路器打开一段时间后，会自动进入“半开”状态

# 二、**Hystrix**舱壁模式(线程池隔离策略)

![image-20220321011124978](https://cdn.wuzx.cool/image-20220321011124978.png)

如果不进行任何设置，所有熔断方法使用一个Hystrix线程池(10个线程)，那么这 样的话会导致问题，这个问题并不是扇出链路微服务不可用导致的，而是我们的线 程机制导致的，如果方法A的请求把10个线程都用了，方法2请求处理的时候压根都 没法去访问B，因为没有线程可用，并不是B服务不可用。

![image-20220321011205285](https://cdn.wuzx.cool/image-20220321011205285.png)

为了避免问题服务请求过多导致正常服务无法访问，Hystrix 不是采用增加线程数， 而是单独的为每一个控制方法创建一个线程池的方式，这种模式叫做“舱壁模式"，也 是线程隔离的手段。

# 三、**Hystrix**工作流程与高级应用

![image-20220321011234980](https://cdn.wuzx.cool/image-20220321011234980.png)

+ 1)当调用出现问题时，开启一个时间窗(10s)
+  2)在这个时间窗内，统计调用次数是否达到最小请求数? 如果没有达到，则重置统计信息，回到第1步 如果达到了，则统计失败的请求数占所有请求数的百分比，是否达到阈值? 如果达到，则跳闸(不再请求对应服务) 如果没有达到，则重置统计信息，回到第1步
+ 3)如果跳闸，则会开启一个活动窗口(默认5s)，每隔5s，Hystrix会让一个请求 通过,到达那个问题服务，看 是否调用成功，如果成功，重置断路器回到第1步，如 果失败，回到第3步

``` java
 
/**
* 8秒钟内，请求次数达到2个，并且失败率在50%以上，就跳闸 * 跳闸后活动窗口设置为3s
*/
    @HystrixCommand(
            commandProperties = {
                    @HystrixProperty(name =
"metrics.rollingStats.timeInMilliseconds",value = "8000"),
                    @HystrixProperty(name =
"circuitBreaker.requestVolumeThreshold",value = "2"),
                    @HystrixProperty(name =
"circuitBreaker.errorThresholdPercentage",value = "50"),
                    @HystrixProperty(name =
"circuitBreaker.sleepWindowInMilliseconds",value = "3000")
} )
```

