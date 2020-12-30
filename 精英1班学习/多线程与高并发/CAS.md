##  CAS(无锁优化 自旋)

compare and swap的缩写，中文翻译成比较并交换。

```
cas原理
cas（V,Expected,NewValue）

​   if v == expected

​		v = newValue

​	else try again or fail
CPU 原语支持
```

```
AtomicInteger
```



## ABA问题

解决办法：版本version





## Unsafe(直接操作JVM内存)

+ 这个类是直接操作内存
  + allocateMemory putXX freeMemory pageSize
+ 直接生成类实例
  + allocateInstance
+ 直接操作类或实例变量
  + ObjectFieldOffset
  + getInt
  + getObject
+ CAS相关操作
  + compareAndSwapObject int Long

