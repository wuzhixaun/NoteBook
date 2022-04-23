 [Toc]

# 一、简介



Java Microbenchmark Harness 

由简介可知，JMH不止能对Java语言做基准测试，还能对运行在JVM上的其他语言做基准测试。而且可以分析到纳秒级别。



# 二、怎么使用



+ 设置jmh依赖

+ 使用GenerateMicroBenchmark注解

## 创建JMH测试

  ### 1、创建maven项目，添加依赖

```xml
<dependency>
  <groupId>org.openjdk.jmh</groupId>
  <artifactId>jmh-core</artifactId>
  <version>1.21</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.openjdk.jmh/jmh-generator-annprocess -->
<dependency>
  <groupId>org.openjdk.jmh</groupId>
  <artifactId>jmh-generator-annprocess</artifactId>
  <version>1.21</version>
  <scope>test</scope>
</dependency>
```

  ### 2、idea安装JMH插件 JMH plugin v1.0.3

### 3、由于用到了注解，打开运行程序的注解配置

> Complier->Annotation processors->enable Annotation processing

### 4、定义需要测试类PS（parallelStream）

```java
    @Benchmark                        // 测试那一块代码
    @Warmup(iterations = 1, time = 3) // 预热，JVM先起来调用这个方法一次，等3s
    @Fork(5)   //用多少线程执行这个程序
    @BenchmarkMode(Mode.Throughput)   // 基本测试模式，吞吐量
    @Measurement(iterations = 1, time = 3)  // 总共执行多少次测试
    public void testForeach() {
        PS.foreach();
    }
```



