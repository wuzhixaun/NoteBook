Tomcat中的各容器组件都会涉及创建、销毁等，因此设计了⽣命周期接⼝Lifecycle进⾏统⼀规范，各容器组件实现该接⼝

# 一、**Lifecycle**接口

## 1.1 Lifecycle⽣命周期接⼝主要⽅法示意

![image-20211206103359775](https://cdn.wuzx.cool/image-20211206103359775.png)

## 1.2 Lifecycle⽣命周期接⼝继承体系示意

![image-20211206104255371](https://cdn.wuzx.cool/image-20211206104255371.png)

# 二、**核⼼流程源码剖析**

源码追踪部分我们关注两个流程：`Tomcat启动流程`和`Tomcat请求处理流程`

## 2.1 Tomcat启动流程

![image-20211206105932681](https://cdn.wuzx.cool/image-20211206105932681.png)

## 2.2. Tomcat请求处理流程

### 2.2.1 请求处理流程分析 

![image-20211206225751105](https://cdn.wuzx.cool/image-20211206225751105.png)

### 2.2.2 请求处理流程示意图

![image-20211206225824409](https://cdn.wuzx.cool/image-20211206225824409.png)

### 2.2.3 Mapper组件体系结构

![image-20211206230037495](https://cdn.wuzx.cool/image-20211206230037495.png)

# 三、**Tomcat** 类加载机制剖析

Java类(.java)—> 字节码文件(.class) —> 字节码文件需要被加载到jvm内存当中(这个过程就是一个 类加载的过程)

类加载器(ClassLoader，说白了也是一个类，jvm启动的时候先把类加载器读取到内存当中去，其他的 类(比如各种jar中的字节码文件，自己开发的代码编译之后的.class文件等等))

要说 Tomcat 的类加载机制，首先需要来看看 Jvm 的类加载机制，因为 Tomcat 类加载机制是在 Jvm 类 加载机制基础之上进行了一些变动。

## 3.1 **JVM** 的类加载机制

引导类加载器、扩展类加载器、系统类加载器，他们之间形成父子关 系，通过 Parent 属性来定义这种关系，最终可以形成树形结构。

![image-20211206230800131](https://cdn.wuzx.cool/image-20211206230800131.png)

| 类加载器                                      | 作用                                                         |
| --------------------------------------------- | ------------------------------------------------------------ |
| 引导启动类加载器BootstrapClassLoader          | c++编写，加载java核心库 java.*,比如rt.jar中的类，构 造ExtClassLoader和AppClassLoader |
| 扩展类加载器 ExtClassLoader                   | java编写，加载扩展库 JAVA_HOME/lib/ext目录下的jar 中的类，如classpath中的jre ，javax.*或者java.ext.dir 指定位置中的类 |
| 系统类加载器 SystemClassLoader/AppClassLoader | 默认的类加载器，搜索环境变量 classpath 中指明的路 径         |

## 3.2 双亲委派机制

```
当某个类加载器需要加载某个.class文件时，它首先把这个任务委托给他的上级类加载器，递归这个操作，如果上级的类加载器没有加载，自己才会去加载这个类
```

###  双亲委派机制的作用

+ 防止重复加载同一个.class。通过委托去向上面问一问，加载过了，就不用再加载一遍。保证数据

  安全

+ 保证核心.class不能被篡改。通过委托方式，不会去篡改核心.class，即使篡改也不会去加载，即使 加载也不会是同一个.class对象了。不同的加载器加载同一个.class也不是同一个.class对象。这样 保证了class执行安全(如果子类加载器先加载，那么我们可以写一些与java.lang包中基础类同名 的类， 然后再定义一个子类加载器，这样整个应用使用的基础类就都变成我们自己定义的类了。 )

Object类 -----> 自定义类加载器(会出现问题的，那么真正的Object类就可能被篡改了)

# 四、**HTTPS**工作原理

![image-20211206233037796](https://cdn.wuzx.cool/image-20211206233037796.png)

# 五、**Tomcat** 性能优化策略

## 5.1 虚拟机运行优化

Java 虚拟机的运行优化主要是内存分配和垃圾回收策略的优化:

+ 内存直接影响服务的运行效率和吞吐量
+ 垃圾回收机制会不同程度地导致程序运行中断(垃圾回收策略不同，垃圾回收次数和回收效率都是
    不同的)

###  Java 虚拟机内存相关参数

| 参数                   | 参数作用                                           | 优化建议                 |
| ---------------------- | -------------------------------------------------- | ------------------------ |
| -server                | 启动Server，以服务端模式运行                       | 服务端模式建议开启       |
| -Xms                   | 最小堆内存                                         | 建议与-Xmx设置相 同      |
| -Xmx                   | 最大堆内存                                         | 建议设置为可用内存 的80% |
| -XX:MetaspaceSize      | 元空间初始值                                       |                          |
| \- XX:MaxMetaspaceSize | 元空间最大内存                                     | 默认无限                 |
| -XX:NewRatio           | 年轻代和老年代大小比值，取值为整数，默 认为2       | 不需要修改               |
| -XX:SurvivorRatio      | Eden区与Survivor区大小的比值，取值为整 数，默认为8 | 不需要修改               |

### **JVM**内存模型回顾

![image-20211206235547481](https://cdn.wuzx.cool/image-20211206235547481.png)

参数调整示例

``` shell
  JAVA_OPTS="-server -Xms2048m -Xmx2048m -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m"
```

# 六、**Tomcat** 配置调优

## 6.1调整tomcat线程池

![image-20211207000923032](https://cdn.wuzx.cool/image-20211207000923032.png)

## 6.2 调整tomcat的连接器

![image-20211207000959063](https://cdn.wuzx.cool/image-20211207000959063.png)

## 6.3 禁用 AJP 连接器

![image-20211207001025507](https://cdn.wuzx.cool/image-20211207001025507.png)

## 6.4 调整 IO 模式

Tomcat8之前的版本默认使用BIO(阻塞式IO)，对于每一个请求都要创建一个线程来处理，不适合高并发;Tomcat8以后的版本默认使用NIO模式(非阻塞式IO)

![image-20211207001052314](https://cdn.wuzx.cool/image-20211207001052314.png)

## 6.5 动静分离

可以使用Nginx+Tomcat相结合的部署方案，Nginx负责静态资源访问，Tomcat负责Jsp等动态资 源访问处理(因为Tomcat不擅⻓处理静态资源)。
