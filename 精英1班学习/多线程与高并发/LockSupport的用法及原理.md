

## 概述

`LockSupport`是一个线程阻塞工具类，所有的方法都是静态方法，可以让线程在任意位置阻塞，当然阻塞之后肯定得有唤醒的方法。



```
public static void park(Object blocker); // 暂停当前线程
public static void parkNanos(Object blocker, long nanos); // 暂停当前线程，不过有超时时间的限制
public static void parkUntil(Object blocker, long deadline); // 暂停当前线程，直到某个时间
public static void park(); // 无期限暂停当前线程
public static void parkNanos(long nanos); // 暂停当前线程，不过有超时时间的限制
public static void parkUntil(long deadline); // 暂停当前线程，直到某个时间
public static void unpark(Thread thread); // 恢复当前线程
public static Object getBlocker(Thread t);
```





### 区别

这儿`park`和`unpark`其实实现了`wait`和`notify`的功能，不过还是有一些差别的。

+ `park`不需要获取某个对象的锁
+ 因为中断的时候`park`不会抛出`InterruptedException`异常，所以需要在`park`之后自行判断中断状态，然后做额外的处理



#  总结

`park和unpark`可以实现类似`wait和notify`的功能，但是并不和`wait和notify`交叉，也就是说`unpark`不会对`wait`起作用，`notify`也不会对`park`起作用。

`park和unpark`的使用不会出现死锁的情况

blocker的作用是在dump线程的时候看到阻塞对象的信息

