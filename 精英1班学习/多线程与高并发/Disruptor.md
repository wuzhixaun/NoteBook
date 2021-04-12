# 特点

无锁、高并发，使用环形buffer,直接覆盖(不用清楚)旧数据，降低GC频率实现了基于时间的生产者消费者模式（观察者模式）

# RingBuffer

RIngBuffer的序号，指向下一个可用的元素

对比ConcurrentLinkedQueue,用数组实现的速度更快

> 例如长度为8，当添加到第12个元素的时候在那个序号上？用12%8决定
>
> 当buffer 呗填满的时候到底是覆盖还是等待，由producer决定
>
> 长度为2的n次幂，利于二进制计算，例如

# Disruptor的核心

# 开发步骤

+ 定义Event-队列需要处理的元素
+ 定义Event工厂，用于填充队列
+ 定义EventHandler(消费者),处理容器中的元素

# 事件发布模板



