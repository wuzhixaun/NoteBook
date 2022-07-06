# 一、Tomcat参数调优(优化吞吐量)

## 1.1 禁用AJP服务

> 什么是AJP呢 AJP(Apache JServer Protocol)是定向包协议 。WEB服务器和Servlet容器通过TCP连接来交互;为 了节省SOCKET创建的昂贵代价，WEB服务器会尝试维护一个永久TCP连接到servlet容器，并且在多个请求和响应周 期过程会重用连接。
>
> Tomcat在 server.xml 中配置了两种连接器。
>
> +  第一个连接器监听8080端口，负责建立HTTP连接。在通过浏览器访问Tomcat服务器的Web应用时，使用的就 是这个连接器。
> + 第二个连接器监听8009端口，负责和其他的HTTP服务器建立连接。在把Tomcat与其他HTTP服务器集成时， 就需要用到这个连接器。AJP连接器可以通过AJP协议和一个web容器进行交互

Nginx+tomcat的架构，所以用不着AJP协议，所以把AJP连接器禁用。修改conf下的server.xml文件，将AJP服务禁用 掉即可。

![image-20220523012657840](https://cdn.wuzx.cool/image-20220523012657840.png)

## 1.2  设置执行器(线程池)

频繁地创建线程会造成性能浪费，所以使用线程池来优化: 在tomcat中每一个用户请求都是一个线程，所以可以使用线程池提高性能。

``` xml
 <!--将注释打开-->
<Executor name="tomcatThreadPool" namePrefix="catalina‐exec‐" maxThreads="500" minSpareThreads="50" prestartminSpareThreads="true" maxQueueSize="100"/>
<!--
参数说明:
maxThreads:最大并发数，默认设置 200，一般建议在 500 ~ 1000，根据硬件设施和业务来判断 minSpareThreads:Tomcat 初 始 化 时 创 建 的 线 程 数 ， 默 认 设 置 25
prestartminSpareThreads: 在 Tomcat 初始化的时候就初始化 minSpareThreads 的参数值，如果不等于 true， minSpareThreads 的值就没啥效果了
maxQueueSize，最大的等待队列数，超过则拒绝请求
-->
 <!-- A "Connector" represents an endpoint by which requests are received
         and responses are returned. Documentation at :
         Java HTTP Connector: /docs/config/http.html
         Java AJP  Connector: /docs/config/ajp.html
         APR (HTTP/AJP) Connector: /docs/apr.html
         Define a non-SSL/TLS HTTP/1.1 Connector on port 8080
 -->
    <Connector port="8080" executor="tomcatThreadPool"  protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <!-- A "Connector" using the shared thread pool-->
```

## 1.3 设置最大等待队列

默认情况下，请求发送到tomcat，如果tomcat正忙，那么该请求会一直等待。这样虽然 可以保证每个请求都能请求 到，但是请求时间就会边长。

有些时候，我们也不一定要求请求一定等待，可以设置最大等待队列大小，如果超过就不等待了。这样虽然有些请
求是失败的，但是请求时间会虽短

``` XML
 <!‐‐最大等待数为100‐‐>
<Executor name="tomcatThreadPool" namePrefix="catalina‐exec‐" maxThreads="500" minSpareThreads="100"
prestartminSpareThreads="true" maxQueueSize="100"/>
```

## 1.4 设置nio2的运行模式

> tomcat的运行模式有3种:
>
> + bio 默认的模式,性能非常低下,没有经过任何优化处理和支持.
> + nio nio(new I/O)，是Java SE 1.4及后续版本提供的一种新的I/O操作方式(即java.nio包及其子包)。Java nio是一个基 于缓冲区、并能提供非阻塞I/O操作的Java API，因此nio 也被看成是non-blocking I/O的缩写。它拥有比传统I/O操作 (bio)更好的并发运行性能。
> + apr 安装起来最困难,但是从操作系统级别来解决异步的IO问题,大幅度的提高性能. 推荐使用nio，不过，在 tomcat8中有最新的nio2，速度更快，建议使用nio2. 设置nio2

``` XML
 <Connector executor="tomcatThreadPool"  port="8080"
protocol="org.apache.coyote.http11.Http11Nio2Protocol"
connectionTimeout="20000" redirectPort="8443" />
```



# 二、调整JVM参数进行优化

## 2.1 设置并行垃圾回收器

``` java
 #年轻代、老年代均使用并行收集器，初始堆内存64M，最大堆内存512M
JAVA_OPTS="-XX:+UseParallelGC -XX:+UseParallelOldGC -Xms64m -Xmx512m -XX:+PrintGCDetails - XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xloggc:../logs/gc.log"
```

展示测试结果:

![image-20220523013022969](https://cdn.wuzx.cool/image-20220523013022969.png)

查看gc日志文件 将gc.log文件上传到gceasy.io查看gc中是否存在问题。

### 修改 tomcat的 catalina.sh:

将jvm参数添加进去--设置年轻代和老年代的垃圾收集器均为ParallelGC并行垃圾收集器。不设置jdk8默认也是使用 ParallelGC:

![image-20220523013109384](https://cdn.wuzx.cool/image-20220523013109384.png)

### 查看GC日志文件

#### 问题一: 年轻代和老年代空间大小分配不合理, 具体如下图

![image-20220523013150603](https://cdn.wuzx.cool/image-20220523013150603.png)

#### 问题二: 0-100事件范围内执行MinorGC 太多

![image-20220523013208488](https://cdn.wuzx.cool/image-20220523013208488.png)

从图中可以看到0-100 100-200毫秒的gc 发生了9次和4次, 时间短,频率高,说明年轻代空间分配不合理,我们可以尝试 多给年轻代分配空间,减少Minor GC 频率, 降低Pause GC事件,提高吞吐量.

#### 问题三:下图中我们也能看到问题, Minor GC 发生了 14 次, Full GC 发生了2次。 Pause time 事件也较长。

![image-20220523013239398](https://cdn.wuzx.cool/image-20220523013239398.png)

## 2.2 调整年轻代大小

调整JVM参数

``` xml
# 对比下之前的配置，将初始堆大小，年轻代大小均进行提升
JAVA_OPTS="-XX:+UseParallelGC -XX:+UseParallelOldGC -Xms512m -Xmx512m -XX:NewRatio=2 -
XX:SurvivorRatio=8 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -
XX:+PrintHeapAtGC -Xloggc:../logs/gc.log"
```

### 查看GC日志

![image-20220523013344576](https://cdn.wuzx.cool/image-20220523013344576.png)

**效果:吞吐量保持在97%以上，同时Minor GC次数明显减少，停顿次数减少**

## 2.3 设置G1垃圾收集器

> 理论上而言，设置为G1垃圾收集器，性能是会提升的。但是会受制于多方面的影响，也不一定绝对有提升。

设置JVM参数

``` xml
 
#设置使用G1垃圾收集器最大停顿时间100毫秒，初始堆内存512m，最大堆内存512m
JAVA_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=100 -Xms512m -Xmx512m -XX:+PrintGCDetails - XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xloggc:../logs/gc.log"
```

![image-20220523013450818](https://cdn.wuzx.cool/image-20220523013450818.png)由上图可以看到吞吐量上升, GC执行次数降低.