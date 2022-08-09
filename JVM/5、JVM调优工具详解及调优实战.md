# 一、Jmap

> jmap 可以查看内存信息、实例个数、内存大小

## 1.1 histo

+ `jmap -histo pid `:统计堆中对象数目、大小
+ `jmap -histo:live pid`统计堆中活对象的数目、大小 
+ num:序号  instances:实例数量  bytes:占用空间大小
+ class name:类名称，[C is a char[]，[S is a short[]，[I is a int[]，[B is a byte[]，[[I is a int[][]

![image-20220808223545585](https://cdn.wuzx.cool/image-20220808223545585.png)

## 1.2 堆信息

`jmap -heap pid `:查看堆信息

![image-20220808230721142](https://cdn.wuzx.cool/image-20220808230721142.png)

## 1.3 堆内存dump

`jmap‐dump:format=b,file=eureka.hprof14660 `

也可以设置内存溢出自动导出dump文件(内存很大的时候，可能会导不出来)

1. -XX:+HeapDumpOnOutOfMemoryError
2. -XX:HeapDumpPath=./ (路径)

**可以用jvisualvm命令工具导入该dump文件分析**

![image-20220808232719471](https://cdn.wuzx.cool/image-20220808232719471.png)

## 1.4 jstack

> 用jstack加进程id查找死锁，见如下示例`jstack -pid`

![image-20220808233805073](https://cdn.wuzx.cool/image-20220808233805073.png)

### 使用jvisualVM

![image-20220808233917448](https://cdn.wuzx.cool/image-20220808233917448.png)

![image-20220808233944482](https://cdn.wuzx.cool/image-20220808233944482.png)

## **jstack找出占用cpu最高的线程堆栈信息**

+ 使用命令top -p <pid> ，显示你的java进程的内存情况，pid是你的java进程号，比如19663

  ![image-20220809000205985](https://cdn.wuzx.cool/image-20220809000205985.png)

+ 按H，获取每个线程的内存情况

  ![image-20220809000229330](https://cdn.wuzx.cool/image-20220809000229330.png)

+ 找到内存和cpu占用最高的线程tid，比如19664
+ 转为十六进制得到 0x4cd0，此为线程id的十六进制表示
+ 执行 jstack 19663|grep -A 10 4cd0，得到线程堆栈信息中 4cd0 这个线程所在行的后面10行，从堆栈中可以发现导致cpu飙高的调 用方法
+ 查看对应的堆栈信息找出可能存在问题的代码

## 远程连接jvisualvm

> 启动普通的jar程序JMX端口配置:
>
> ``` shell
> java‐Dcom.sun.management.jmxremote.port=8888‐Djava.rmi.server.hostname=192.168.50.60‐Dcom.sun.management.jmxremot e.ssl=false ‐Dcom.sun.management.jmxremote.authenticate=false ‐jar microservice‐eureka‐server.jar
> ```
>
> PS:
>
> + -Dcom.sun.management.jmxremote.port 为远程机器的JMX端口
> + -Djava.rmi.server.hostname 为远程机器IP

# 二、jinfo

> 查看正在运行的Java应用程序的扩展参数

`jinfo -flags pid`查看jvm参数

![image-20220809001947730](https://cdn.wuzx.cool/image-20220809001947730.png)

`jinfo -sysprops pid` 查看java系统参数

![image-20220809002036803](https://cdn.wuzx.cool/image-20220809002036803.png)

# 三、jstat(最重要)

jstat命令可以查看堆内存各部分的使用量，以及加载类的数量。命令的格式如下:

## 垃圾回收统计

`jstat -gc pid 最常用，可以评估程序内存使用及GC压力整体情况`

![image-20220809002733811](https://cdn.wuzx.cool/image-20220809002733811.png)

+ S0C:第一个幸存区的大小，单位KB 
+ S1C:第二个幸存区的大小 
+ S0U:第一个幸存区的使用大小
+ S1U:第二个幸存区的使用大小
+ EC:伊甸园区的大小 
+ EU:伊甸园区的使用大小 
+ OC:老年代大小
+ OU:老年代使用大小 
+ MC:方法区大小(元空间) 
+ MU:方法区使用大小 
+ CCSC:压缩类空间大小
+ CCSU:压缩类空间使用大小 
+ YGC:年轻代垃圾回收次数 
+ YGCT:年轻代垃圾回收消耗时间，单位s 
+ FGC:老年代垃圾回收次数 
+ FGCT:老年代垃圾回收消耗时间，单位s 
+ GCT:垃圾回收消耗总时间，单位s

## 堆内存统计

`jstat -gccapacity pid`

![image-20220809002958176](https://cdn.wuzx.cool/image-20220809002958176.png)

+ NGCMN:新生代最小容量 
+ NGCMX:新生代最大容量 
+ NGC:当前新生代容量 
+ S0C:第一个幸存区大小 
+ S1C:第二个幸存区的大小 
+ EC:伊甸园区的大小 
+ OGCMN:老年代最小容量 
+ OGCMX:老年代最大容量 
+ OGC:当前老年代大小 
+ OC:当前老年代大小 
+ MCMN:最小元数据容量 
+ MCMX:最大元数据容量 
+ MC:当前元数据空间大小 
+ CCSMN:最小压缩类空间大小 
+ CCSMX:最大压缩类空间大小
+  CCSC:当前压缩类空间大小 
+ YGC:年轻代gc次数 
+ FGC:老年代GC次数

## 新生代垃圾回收统计

`jstat -gcnew pid`

![image-20220809003231432](https://cdn.wuzx.cool/image-20220809003231432.png)

+ S0C:第一个幸存区的大小 
+ S1C:第二个幸存区的大小
+ S0U:第一个幸存区的使用大小 
+ S1U:第二个幸存区的使用大小 
+ TT:对象在新生代存活的次数 
+ MTT:对象在新生代存活的最大次数 
+ DSS:期望的幸存区大小 
+ EC:伊甸园区的大小 
+ EU:伊甸园区的使用大小 
+ YGC:年轻代垃圾回收次数 
+ YGCT:年轻代垃圾回收消耗时间

## 新生代内存统计

`jstat -gcnewcapacity pid`

+ NGCMN:新生代最小容量 
+ NGCMX:新生代最大容量 
+ NGC:当前新生代容量 
+ S0CMX:最大幸存1区大小 
+ S0C:当前幸存1区大小 
+ S1CMX:最大幸存2区大小 
+ S1C:当前幸存2区大小 
+ ECMX:最大伊甸园区大小 
+ EC:当前伊甸园区大小 
+ YGC:年轻代垃圾回收次数 
+ FGC:老年代回收次数

## 老年代垃圾回收统计

`jstat -gcold pid`

![image-20220809003058866](https://cdn.wuzx.cool/image-20220809003058866.png)

+ MC:方法区大小
+  MU:方法区使用大小 
+ CCSC:压缩类空间大小 
+ CCSU:压缩类空间使用大小 
+ OC:老年代大小 
+ OU:老年代使用大小 
+ YGC:年轻代垃圾回收次数
+ FGC:老年代垃圾回收次数 
+ FGCT:老年代垃圾回收消耗时间 
+ GCT:垃圾回收消耗总时间

## 老年代内存统计

`jstat -gcoldcapacity pid`

+ OGCMN:老年代最小容量 
+ OGCMX:老年代最大容量 
+ OGC:当前老年代大小 
+ OC:老年代大小 
+ YGC:年轻代垃圾回收次数 
+ FGC:老年代垃圾回收次数 
+ FGCT:老年代垃圾回收消耗时间 
+ GCT:垃圾回收消耗总时间

## 元数据空间统计

`jstat -gcmetacapacity pid`

+ MCMN:最小元数据容量 
+ MCMX:最大元数据容量 
+ MC:当前元数据空间大小 
+ CCSMN:最小压缩类空间大小 
+ CCSMX:最大压缩类空间大小 
+ CCSC:当前压缩类空间大小 
+ YGC:年轻代垃圾回收次数 
+ FGC:老年代垃圾回收次数 
+ FGCT:老年代垃圾回收消耗时间 
+ GCT:垃圾回收消耗总时间

# 四、系统频繁Full GC导致系统卡顿是怎么回事

+ 机器配置:2核4G
+ JVM内存大小:2G
+  系统运行时间:7天
+ 期间发生的Full GC次数和耗时:500多次，200多秒 
+ 期间发生的Young GC次数和耗时:1万多次，500多秒

>  大致算下来每天会发生70多次Full GC，平均每小时3次，每次Full GC在400毫秒左右; 
>
> 每天会发生1400多次Young GC，每分钟会发生1次，每次Young GC在50毫秒左右。

JVM参数设置

![image-20220809015830329](https://cdn.wuzx.cool/image-20220809015830329.png)

``` she
‐Xms1536M ‐Xmx1536M ‐Xmn512M ‐Xss256K ‐XX:SurvivorRatio=6 ‐XX:MetaspaceSize=256M -XX:MaxMetaspaceSize=256M ‐XX:+UseParNewGC ‐XX:+UseConcMarkSweepGC ‐XX:CMSInitiatingOccupancyFraction=75 ‐XX:+UseCMSInitiatingOccupancyOnly
```

通过命令 jsta -gc pid 1000 10000 每隔1000毫秒打印1次，循环10000次

![image-20220809021347909](https://cdn.wuzx.cool/image-20220809021347909.png)

## 首先猜测 对象直接进入老年代的规则

+ 大对象，会直接进入老年代
+ 对象动态年龄判断机制
  + 一批分代年龄相同的对象总的大小之和如果超过suvirvor的50%(-XX:TargetSuvivorRadio)会将这批对象直接晋升到老年代
+ 老年代空间分配保护机制

## 经过分析感觉可能是`对象动态年龄判断机制`导致的频繁full gc

+ 那么我们就尝试着调整一下JVM参数，将年轻代的调整大一些，因为总是触发full gc所以将‐XX:CMSInitiatingOccupancyFraction=92 调整到

  > -Xms1536M -Xmx1536M -Xmn1024M -Xss256K ‐XX:SurvivorRatio=6 ‐XX:MetaspaceSize=256M -XX:MaxMetaspaceSize=256M ‐XX:+UseParNewGC ‐XX:+UseConcMarkSweepGC ‐XX:CMSInitiatingOccupancyFraction=92 ‐XX:+UseCMSInitiatingOccupancyOnly

  ![image-20220809021829419](https://cdn.wuzx.cool/image-20220809021829419.png)

## 优化完发现没什么变化，full gc的次数比minor gc的次数还多了

+ 通过`jstat -gc pid 1000 20000`

  ![image-20220809021945636](https://cdn.wuzx.cool/image-20220809021945636.png)

## 分析推测full gc比minor gc还多的原因有哪些?

+ 元空间不够，导致full GC
+ 显示调用System.gc()造成多余的full gc，这种一般线上尽量通过­XX:+DisableExplicitGC参数禁用，如果加上了这个JVM启动参数，那 么代码中调用System.gc()没有任何效果
+ 老年代空间分配担保机制(2次full gc 1次minor gc )full gc 完成触发minor gc 然后触发阙值，又触发full GC

**最快速度分析完这些我们推测的原因以及优化后，我们发现young gc和full gc依然很频繁了，而且看到有大量的对象频繁的被挪动到老年 代，这种情况我们可以借助jmap命令大概看下是什么对象**

![image-20220809022307757](https://cdn.wuzx.cool/image-20220809022307757.png)

查到了有大量User对象产生，这个可能是问题所在，但不确定，还必须找到对应的代码确认，如何去找对应的代码了? 1、代码里全文搜索生成User对象的地方(适合只有少数几处地方的情况) 2、如果生成User对象的地方太多，无法定位具体代码，我们可以同时分析下占用cpu较高的线程，一般有大量对象不断产生，对应的方法 代码肯定会被频繁调用，占用的cpu必然较高

可以用上面讲过的jstack或jvisualvm来定位cpu使用较高的代码，结论。。。

同时，java的代码也是需要优化的，一次查询出500M的对象出来，明显不合适，要根据之前说的各种原则尽量优化到合适的值，尽量消 除这种朝生夕死的对象导致的full gc