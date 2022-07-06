# 一、什么是JVM

## 1.1 什么是JVM

VM是Java Virtual Machine(Java虚拟机)的缩写，JVM是一种用于计算设备的规范，它是一个虚构出来的计算机，是通过在实际的计算机上仿真模拟各种计算机功能来实现的。

> 主流虚拟机

| 虚拟机名称 | 介绍                                                         |
| :--------- | ------------------------------------------------------------ |
| HotSpot    | Oracle/Sun JDK和OpenJDK都使用HotSPot VM的相同核心            |
| J9         | J9是IBM开发的高度模块化的JVM                                 |
| JRockit    | JRockit 与 HotSpot 同属于 Oracle，目前为止 Oracle 一直在推进 HotSpot 与 JRockit 两款各有优势的虚拟机进行融合互补 |
| Zing       | 由Azul Systems根据HostPot为基础改进的高性能低延迟的JVM       |
| Dalvik     | Android上的Dalvik 虽然名字不叫JVM，但骨子里就是不折不扣的JVM |

## 1.2 JVM与操作系统

> Java 是一门抽象程度特别高的语言，提供了自动内存管理等一系列的特性。这些特性直接在操作系统上实现是不太 可能的，所以就需要 JVM 进行一番转换。

![image-20220511002503390](https://cdn.wuzx.cool/image-20220511002503390.png)

从图中可以看到，有了 JVM 这个抽象层之后，Java 就可以实现跨平台了。JVM 只需要保证能够正确执行 .class 文 件，就可以运行在诸如 Linux、Windows、MacOS 等平台上了。

## 应用程序、JVM、操作系统之间的关系

![image-20220511002556484](https://cdn.wuzx.cool/image-20220511002556484.png)



**我们用一句话概括 JVM 与操作系统之间的关系:JVM 上承开发语言，下接操作系统，它的中间接口就是字节码。**

## 1.3 JVM、JRE、JDK 的关系

![image-20220511002630412](https://cdn.wuzx.cool/image-20220511002630412.png)

JVM 是 Java 程序能够运行的核心。但是需要注意，JVM 自己什么也干不了，你需要给它提供生产原料(.class 文 件) 

` JRE(Java Runtime Environment)`: JVM 标准加上实现的一大堆基础类库，就组成 了 Java 的运行时环境

` JDK(Java Development Kit)`:除了 JRE，JDK 还提供了一些非常好用的小工具，比如 javac、java、jar 等。它 是 Java 开发的核心，让外行也可以炼剑!

![image-20220511002840957](https://cdn.wuzx.cool/image-20220511002840957.png)

# 二、 java虚拟机的内存管理

## 2.1 JVM整体架构

> JVM 内存共分为: `虚拟机栈`、`堆`、`方法区`、`本地方法栈`、`PC程序计数器`五个部分

![image-20220511003142724](https://cdn.wuzx.cool/image-20220511003142724.png)

> JVM分为五大模块:`类装载子系统`、`运行时数据区`、`执行引擎`、`本地方法接口`和垃圾回收模块

![image-20220511003333577](https://cdn.wuzx.cool/image-20220511003333577.png)

## 2.2 JVM运行时内存

> Java 虚拟机有自动内存管理机制，如果出现面的问题，排查错误就必须要了解虚拟机是怎样使用内存的

![image-20220511003515620](https://cdn.wuzx.cool/image-20220511003515620.png)

### 2.2.1 Java7和Java8内存结构的不同主要体现在方法区的实现

#### JDK7 内存结构

![image-20220511003552404](https://cdn.wuzx.cool/image-20220511003552404.png)

#### JDK8 的内存结构

![image-20220511003609668](https://cdn.wuzx.cool/image-20220511003609668.png)

#### JDK8虚拟机内存详解

![image-20220511003631216](https://cdn.wuzx.cool/image-20220511003631216.png)

#### JDK7和JDK8变化小结

![image-20220511003657643](https://cdn.wuzx.cool/image-20220511003657643.png)

## 2.3 面试题

### 对于Java8，HotSpots取消了永久代，那么是不是就没有方法区了呢?

> 当然不是，方法区只是一个规范，只不过它的实现变了。
>
> 在Java8中，元空间(Metaspace)登上舞台，方法区存在于元空间(Metaspace)。同时，元空间不再与堆连续，而且是 存在于本地内存(Native memory)

### 方法区Java8之后的变化

> + 移除了永久代(PermGen)，替换为元空间(Metaspace)
> + 永久代中的class metadata(类元信息)转移到了native memory(本地内存，而不是虚拟机)
> + 永久代中的interned Strings(字符串常量池) 和 class static variables(类静态变量)转移到了Java heap
> + 永久代参数(PermSize MaxPermSize)-> 元空间参数(MetaspaceSize MaxMetaspaceSize)

### Java8为什么要将永久代替换成Metaspace?

> +  字符串存在永久代中，容易出现性能问题和内存溢出。
> + 类及方法的信息等比较难确定其大小，因此对于永久代的大小指定比较困难，太小容易出现永久代溢出，太 大则容易导致老年代溢出。
> + 永久代会为 GC 带来不必要的复杂度，并且回收效率偏低。