# 一、JVM整体结构及内存模型

![image-20220804003759722](https://cdn.wuzx.cool/image-20220804003759722.png)

# 二、JVM内存参数设置

![image-20220804003845648](https://cdn.wuzx.cool/image-20220804003845648.png)

Spring Boot程序的JVM参数设置格式(Tomcat启动直接加在bin目录下catalina.sh文件里):

``` shell
java -Xms2048 -Xmx2048m -Xmn1024 -Xss512K -XX:MetaspaceSize=256M‐XX:MaxMetaspaceSize=256M -jar xx.jar
```

关于元空间的JVM参数有两个:-XX:MetaspaceSize=N和 -XX:MaxMetaspaceSize=N

`-XX:MaxMetaspaceSize`: 设置元空间最大值， 默认是-1， 即不限制， 或者说只受限于本地内存大小。

`-XX:MetaspaceSize`:指定元空间触发Fullgc的初始阈值(元空间无固定初始大小)以字节为单位，默认是21M，达到该值就会触发 full gc进行类型卸载， 同时收集器会对该值进行调整: 如果释放了大量的空间， 就适当降低该值; 如果释放了很少的空间， 那么在不超 过-XX:MaxMetaspaceSize(如果设置了的话) 的情况下， 适当提高该值。

由于调整元空间的大小需要Full GC，这是非常昂贵的操作，如果应用在启动的时候发生大量Full GC，通常都是由于永久代或元空间发生 了大小调整，基于这种情况，一般建议在JVM参数中将MetaspaceSize和MaxMetaspaceSize设置成一样的值，并设置得比初始值要大， 对于8G物理内存的机器来说，一般我会将这两个值都设置为256M。

-Xss设置越小count值越小，说明一个线程栈里能分配的栈帧就越少，但是对JVM整体来说能开启的线程数会更多