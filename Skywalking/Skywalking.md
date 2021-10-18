# 一、什么是apm

​		Application Performance Management 应用性能管理。APM （Application Performance Management，即应用性能管理，在分布式领域也称为分布式跟踪管理）对企业的应用系统进行实时监控，它是用于实现对应用程序性能管理和故障管理的系统化的解决方案。

![11553600-b62afec3de338966](/Users/wuzhixuan/Downloads/11553600-b62afec3de338966.webp)

# 二、Skywalking 安装

> 默认的是没有监控gateway插件，我们可以将agent->optional-plugins的插件直接移到plugin里面就可以

![image-20210928011237527](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210928011237527.png)



# 三、微服务中服务接入探针



# 四、Skywalking解析

## 1.Global全局纬度

![image-20210928003037336](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210928003037336.png)

+ `Service load`:服务每分钟请求数
+ `Slow Service`:慢响应服务，单位`ms`
+ `Un-Health Services(Apdex)`:Apdex 性能指标，1为满分
  + Apdex 一个有众多王国分析技术公司和测量工业组成的联盟组织，他们联合起来开发了"应用性能指数"即`Apdex(Application performance index)`用一句话概括，Apdex是用户对应用性能满意度的量化值
  + [Apdex网址](http://www.apdex.org)
+ `Slow Endpoints`:慢响应端点，单位ms
+ `Global Response Latency`:百分比响应延迟，不同百分比的延迟时间，单位ms
+ `Global Heatmap`:服务响应时间热力分布图，根据时间段内不同响应时间的数量显色颜色深度（越多访问越黑）

## 2.Service服务纬度

![image-20210928004211745](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210928004211745.png)

+ `Service Apdex(数字)`:当前服务的评分
+ `Service AVG Response times`:平均响应延迟，单位ms
+ `Successful Rate(数字)`:请求成功率
+ `Service Load(数字)`:每分钟请求数
+ `Service Apdex(折线图)`:不同时间的Apdex评分
+ `Service Response time Percentile`:百分比响应延迟
+ `Successful Rate(折线图)`:不同时间的请求成功率
+ `Service Load(数字)`:不同时间的每分钟请求数
+ `Service Instances load`:每个服务实例每分钟请求数
+ `Slow Service Instance`:每个服务的最大延迟
+ `Service Instances Successful Rate`:每个服务实例的请求成功率



## 3.Instance

![image-20210928005058823](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210928005058823.png)

+ `Service Instances load`:当前实例每分钟请求数
+ `Service Instances Successful Rate`:当前实例的请求成功率
+ `Service Instances Latency `:当前实例的响应延迟
+ `JVM CPU`:jvm占用CPU百分比
+ `JVM Memory`:jvm内存占用大小，单位m
+ `JVM GC Time`:jvm垃圾回收时间，包含YGC和OGC
+ `JVM GC Count`:jvm垃圾回收次数，包含YGC和OGC



## 4.EndPoint(接口)

![image-20210928010020436](/Users/wuzhixuan/Library/Application Support/typora-user-images/image-20210928010020436.png)

+ `EndPoint Load in Current Service`:每个端点每分钟请求次数
+ `Slow EndPoint in Current Service`:每个端点最慢请求时间，单位ms
+ `Successful Rate in Current Service`:每个端点的请求成功率
+ `EndPoint Load `:当前端点每个时间段的请求数据
+ `EndPoint AVg Respone Time`:当前端点每个时间段的请求行响应时间
+ `EndPoint AVg Respone Percentile`:当前端点每个时间段的响应时间占比
+ `EndPoint Successful Rate`:当前端点每个时间段的请求成功率
